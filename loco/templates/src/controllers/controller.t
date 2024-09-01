{% macro get_type(property_name, property) %}
    {% set required = property.required and property_name not in property.required %}
    {% if required %}Option<{% endif %}
    
    {# Handle string types with format, check if format exists first #}
    {% if property.type and property.type == "string" %}
        {% if property.format and property.format == "uuid" %}
            uuid::Uuid
        {% elif property.format and property.format == "date-time" %}
            DateTimeWithTimeZone
        {% elif property.format and property.format == "date" %}
            TimeDate
        {% elif property.format and property.format == "time" %}
            TimeTime
        {% else %}
            String
        {% endif %}
    
    {# Handle boolean type #}
    {% elif property.type and property.type == "boolean" %}
        bool
    {% elif property.type and property.type == "integer" %}
        {% set min = property.minimum or property.exclusiveMinimum %}
        {% set max = property.maximum or property.exclusiveMaximum %}
        {% if min and min >= 0 %}
            {% if max and max <= 255 %}
                u8
            {% elif max and max <= 65535 %}
                u16
            {% elif max and max <= 4294967295 %}
                u32
            {% else %}
                u64
            {% endif %}
        {% else %}
            {% if max and max <= 127 %}
                i8
            {% elif max and max <= 32767 %}
                i16
            {% elif max and max <= 2147483647 %}
                i32
            {% else %}
                i64
            {% endif %}
        {% endif %}
    
    {# Handle number types (float) with min/max constraints #}
    {% elif property.type and property.type == "number" %}
        {% set min = property.minimum or property.exclusiveMinimum %}
        {% set max = property.maximum or property.exclusiveMaximum %}
        {% if min or max %}
            {% if min and min >= -3.40282347 and max and max <= 3.40282347 %}
                f32
            {% else %}
                f64
            {% endif %}
        {% else %}
            f64
        {% endif %}
    
    {# Handle enums #}
    {% elif property.enum %}
        {{ property_name | capitalize }}
    {% else %}
        String
    {% endif %}
    
    {%- if required %}>{% endif %}
{% endmacro %}

{% for entity in entities -%}
{% set file_name = entity.title | snake_case -%}
{% set module_name = file_name | pascal_case -%}
to: {{ rootFolder }}/src/controllers/{{ file_name }}.rs
message: "Controller `{{module_name}}` was added successfully."
injections:
- into: {{ rootFolder }}/src/controllers/mod.rs
  create_if_missing: true
  append: true
  content: "pub mod {{ file_name }};"
- into: {{ rootFolder }}/src/app.rs
  after: "AppRoutes::"
  content: "            .add_route(controllers::{{ file_name }}::routes())"
===
#![allow(clippy::missing_errors_doc)]
#![allow(clippy::unnecessary_struct_initialization)]
#![allow(clippy::unused_async)]
use loco_rs::prelude::*;
use serde::{Deserialize, Serialize};
use axum::debug_handler;

use crate::models::_entities::{{file_name | plural}}::{ActiveModel, Entity, Model};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Params {
    {% for property_name, property in entity.properties -%}
        {% if property.type -%}
    pub {{ property_name }}: {{ self::get_type(property_name=property_name, property=property) }}
        {% endif %}
    {% endfor %}
}

impl Params {
    fn update(&self, item: &mut ActiveModel) {
      {% for property_name, property in entity.properties -%}
      {% if property.type -%}
      item.{{property_name}} = Set(self.{{property_name}}.clone());
      {% endif -%}
      {% endfor %}
    }
}

async fn load_item(ctx: &AppContext, id: i32) -> Result<Model> {
    let item = Entity::find_by_id(id).one(&ctx.db).await?;
    item.ok_or_else(|| Error::NotFound)
}

#[debug_handler]
pub async fn list(State(ctx): State<AppContext>) -> Result<Response> {
    format::json(Entity::find().all(&ctx.db).await?)
}

#[debug_handler]
pub async fn add(State(ctx): State<AppContext>, Json(params): Json<Params>) -> Result<Response> {
    let mut item = ActiveModel {
        ..Default::default()
    };
    params.update(&mut item);
    let item = item.insert(&ctx.db).await?;
    format::json(item)
}

#[debug_handler]
pub async fn update(
    Path(id): Path<i32>,
    State(ctx): State<AppContext>,
    Json(params): Json<Params>,
) -> Result<Response> {
    let item = load_item(&ctx, id).await?;
    let mut item = item.into_active_model();
    params.update(&mut item);
    let item = item.update(&ctx.db).await?;
    format::json(item)
}

#[debug_handler]
pub async fn remove(Path(id): Path<i32>, State(ctx): State<AppContext>) -> Result<Response> {
    load_item(&ctx, id).await?.delete(&ctx.db).await?;
    format::empty()
}

#[debug_handler]
pub async fn get_one(Path(id): Path<i32>, State(ctx): State<AppContext>) -> Result<Response> {
    format::json(load_item(&ctx, id).await?)
}

pub fn routes() -> Routes {
    Routes::new()
        .prefix("{{file_name | plural}}")
        .add("/", get(list))
        .add("/", post(add))
        .add("/:id", get(get_one))
        .add("/:id", delete(remove))
        .add("/:id", post(update))
}
---
{% endfor -%}