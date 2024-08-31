{% macro get_type(property_name,property) %}
{% filter nospaces %}
{% set required=property.required and property_name not in property.required %}
{% if required %}Option<{% endif %}
{% if property.type == "string" %}
    {% if format and format == "uuid" %}
    uuid::Uuid
    {% elif format and format == "date-time" %}
    DateTimeWithTimeZone
    {% elif format and format == "date" %}
    TimeDate
    {% elif format and format == "time" %}
    TimeTime
    {% else %}
    String
    {% endif %}
{% elif property.type == "boolean" %}
    bool
{% elif property.type == "integer" %}
    {% if property.minimum or property.exclusiveMinimum or property.maximum or property.exclusiveMaximum %}
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
    {% else %}
        i64
    {% endif %}
{% elif property.type == "number" %}
    {# Handle float based on min/max constraints for floats #}
    {% set min = property.minimum or property.exclusiveMinimum %}
    {% set max = property.maximum or property.exclusiveMaximum %}
    {% if min or max %}
        {% if min and min >= -3.40282347e+38 and max and max <= 3.40282347e+38 %}
            f32
        {% elif min and min >= -1.7976931348623157e+308 and max and max <= 1.7976931348623157e+308 %}
            f64
        {% else %}
            f64
        {% endif %}
    {% else %}
        f64
    {% endif %}
{% elif property.enum == "enum"%}
    {{ property_name }}
{% endif %}

{% if required %}>{% endif %}
{% endfilter %}
{% endmacro type %}

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
    pub {{ property_name }}: {{self::get_type(property_name=property_name, property=property)}}{% if not loop.last -%},{% endif -%}
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

