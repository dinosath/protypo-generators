

{%- macro get_type(name, property) -%}
{% filter trim %}
    {% set required = property.required and name not in property.required -%}
    {% if required -%}Option<{% endif -%}
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
        {{ name | capitalize }}
    {% else -%}
        String
    {% endif -%}
    {%- if required -%}>{% endif -%}
{% endfilter %}
{%- endmacro -%}

{%- macro get_relation(property) -%}
    {% if property['$ref'] -%}
    {{ property['$ref'] | split(pat=".")|first }}
    {%- endif -%}
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


{%- macro seaorm_prelude_imports(entity) -%}
{%- set possible_imports = ['DateTimeWithTimeZone','TimeDate','TimeTime'] -%}
{%- set imports = [] -%}
{% for name,property in entity.properties -%}
    {%- set type = self::get_type(name=name, property=property) -%}
    {% if type in possible_imports -%}
        {%- set imports = imports | concat(with=type) -%}
    {% endif -%}
{% endfor -%}
{%- if imports | length >0 -%}
{{ "use sea_orm::prelude::{"~ imports ~"};"}}
{% else %}
{%- endif %}
{%- endmacro -%}
