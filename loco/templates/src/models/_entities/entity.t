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
message: "Entity `{{module_name}}` was added successfully."
injections:
- into: {{ rootFolder }}/src/controllers/mod.rs
  create_if_missing: true
  append: true
  content: "pub mod {{ file_name }};"
===
use sea_orm::entity::prelude::*;
use serde::{Serialize, Deserialize};

#[derive(Clone, Debug, PartialEq, DeriveEntityModel, Eq, Serialize, Deserialize)]
#[sea_orm(table_name = "{{ file_name | plural }}")]
pub struct Model {
    #[sea_orm(primary_key)]
    pub id: i32,
    pub created_at: DateTime,
    pub updated_at: DateTime,
    {% for property_name, property in entity.properties -%}
        {% if property.type -%}
    pub {{ property_name }}: {{ self::get_type(property_name=property_name, property=property) }}{% if not loop.last -%},{% endif -%}
        {%- endif %}
    {% endfor %}
}

# #[derive(Copy, Clone, Debug, EnumIter, DeriveRelation)]
# pub enum Relation {
#     #[sea_orm(has_many = "super::files::Entity")]
#     Files,
# }

# impl Related<super::files::Entity> for Entity {
#     fn to() -> RelationDef {
#         Relation::Files.def()
#     }
# }
---
{% endfor -%}