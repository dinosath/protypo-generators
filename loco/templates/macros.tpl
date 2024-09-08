{%- macro get_migration_type(name, property) -%}
{% filter trim %}
    {% if property.type and property.type == "string" -%}
        {% if property.format and property.format == "uuid" -%}
            uuid
        {% elif property.format and property.format == "date-time" -%}
            date_time
        {% elif property.format and property.format == "date" -%}
            date_time
        {% elif property.format and property.format == "time" -%}
            time
        {% else -%}
            string
        {% endif -%}    
    {% elif property.type and property.type == "boolean" -%}
        boolean
    {% elif property.type and property.type == "integer" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min and min >= 0 -%}
            {% if max and max <= 255 -%}
                tiny_unsigned
            {% elif max and max <= 65535 -%}
                small_unsigned
            {% elif max and max <= 4294967295 -%}
                unsigned
            {% else -%}
                big_unsigned
            {% endif -%}
        {% else -%}
            {% if max and max <= 127 -%}
                tiny_integer
            {% elif max and max <= 32767 -%}
                small_integer
            {% elif max and max <= 2147483647 -%}
                integer
            {% else -%}
                big_integer
            {% endif -%}
        {% endif -%}
    {% elif property.type and property.type == "number" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min or max -%}
            {% if min and min >= -3.40282347 and max and max <= 3.40282347 -%}
                float
            {% else -%}
                double
            {% endif -%}
        {% else -%}
            double
        {% endif -%}
    {% elif property.enum %}
        enumeration
    {% elif property['x-relationship'] and property['$ref'] %}
        unsigned
    {% else -%}
        string
    {% endif -%}
{% endfilter %}
{%- endmacro -%}

{%- macro get_type(name, property) -%}
{% filter trim %}
    {% if property.type and property.type == "string" -%}
        {% if property.format and property.format == "uuid" -%}
            uuid::Uuid
        {% elif property.format and property.format == "date-time" -%}
            DateTimeWithTimeZone
        {% elif property.format and property.format == "date" -%}
            TimeDate
        {% elif property.format and property.format == "time" -%}
            TimeTime
        {% else -%}
            String
        {% endif -%}    
    {% elif property.type and property.type == "boolean" -%}
        bool
    {% elif property.type and property.type == "integer" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min and min >= 0 -%}
            {% if max and max <= 255 -%}
                u8
            {% elif max and max <= 65535 -%}
                u16
            {% elif max and max <= 4294967295 -%}
                u32
            {% else -%}
                u64
            {% endif -%}
        {% else -%}
            {% if max and max <= 127 -%}
                i8
            {% elif max and max <= 32767 -%}
                i16
            {% elif max and max <= 2147483647 -%}
                i32
            {% else -%}
                i64
            {% endif -%}
        {% endif -%}
    {% elif property.type and property.type == "number" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min or max -%}
            {% if min and min >= -3.40282347 and max and max <= 3.40282347 -%}
                f32
            {% else -%}
                f64
            {% endif -%}
        {% else -%}
            f64
        {% endif -%}
    {% elif property.enum %}
        {{ name | pascal_case }}
    {% elif property['$ref'] and not property['x-relationship']  %}
        {{ name | pascal_case }}    
    {% elif property['x-relationship'] and property['$ref'] %}
        i32
    {% else -%}
        String
    {% endif -%}
    
{% endfilter %}
{%- endmacro -%}


{%- macro get_type_with_option(name, property, required_fields) -%}
{% set required = required_fields and name and name in required_fields -%}
{% if not required -%}Option<{% endif -%}
{{self::get_type(name=name,property=property)}}
{%- if not required -%}>{% endif -%}
{%- endmacro -%}

{%- macro get_name(name, property) -%}
{% filter trim %}
{% if property['x-relationship'] and property['$ref'] %}
    {% set name = name~"Id" -%}
{% endif -%}
{{ name }}
{% endfilter %}
{%- endmacro -%}


{%- macro get_relation(property) -%}
    {% if property['$ref'] -%}
    {{ property['$ref'] | split(pat=".")|first }}
    {%- endif -%}
{%- endmacro -%}

{%- macro get_relation_from_string(string) -%}
{{ string | split(pat=".") | first }}
{%- endmacro -%}


{%- macro relation_is_many_to_one(property) -%}
{{ property['x-relationship'] and property['x-relationship']=="many-to-one"}}
{%- endmacro -%}

{%- macro relation_is_one_to_many(property) -%}
{{ property['x-relationship'] and property['x-relationship']=="one-to-many"}}
{%- endmacro -%}

{%- macro has_many_to_one_relation(entity) -%}
{%- set_global has_many_to_one_relation = false -%}
{% for name,property in entity.properties -%}
    {% if self::relation_is_many_to_one(property=property)=='true' -%}
        {%- set_global has_many_to_one_relation = true -%}
        {% break -%}
    {% endif -%}
{% endfor -%}
{{ has_many_to_one_relation }}
{%- endmacro -%}

{%- macro enum_imports(entity) -%}
{% for name,property in entity.properties -%}
    {% if property['$ref'] and not property['x-relationship'] -%}
        {%- set type = self::get_type(name=name,property=property) | snake_case-%}
        {%- set type_pascal = type | pascal_case -%}
        {{ "use crate::models::enums::" ~ type ~ "::{" ~ type_pascal ~ "};" }}
    {% endif -%}
{% endfor -%}
{%- endmacro -%}

{%- macro seaorm_prelude_imports(entity) -%}
{%- set possible_imports = ['DateTimeWithTimeZone','TimeDate','TimeTime'] -%}
{%- set_global use_imports = [] -%}
{% for name,property in entity.properties -%}
    {%- set type = self::get_type(name=name, property=property) -%}
    {% if type in possible_imports and type not in use_imports -%}
        {%- set_global use_imports = use_imports | concat(with=type) -%}
    {% endif -%}
{% endfor -%}
{% if use_imports | length > 0 -%}
{%- set use_imports_str = use_imports | join(sep=",") -%}
{{ "use sea_orm::prelude::{" ~ use_imports_str ~ "};"}}
{% endif -%}
{%- endmacro -%}