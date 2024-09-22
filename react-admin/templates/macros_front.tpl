{% import "macros.tpl" as macros -%}


{%- macro get_field(property) -%}
{% filter trim %}
    {% if property.type and property.type == "string" -%}
        {% if property.format and property.format == "uuid" -%}
            TextField
        {% elif property.format and property.format == "date-time" -%}
            DateField
        {% elif property.format and property.format == "date" -%}
            DateField
        {% elif property.format and property.format == "time" -%}
            TextField
        {% else -%}
            TextField
        {% endif -%}    
    {% elif property.type and property.type == "boolean" -%}
        TextField
    {% elif property.type and property.type == "integer" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min and min >= 0 -%}
            {% if max and max <= 255 -%}
                TextField
            {% elif max and max <= 65535 -%}
                TextField
            {% elif max and max <= 4294967295 -%}
                TextField
            {% else -%}
                TextField
            {% endif -%}
        {% else -%}
            {% if max and max <= 127 -%}
                TextField
            {% elif max and max <= 32767 -%}
                TextField
            {% elif max and max <= 2147483647 -%}
                TextField
            {% else -%}
                TextField
            {% endif -%}
        {% endif -%}
    {% elif property.type and property.type == "number" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min or max -%}
            {% if min and min >= -3.40282347 and max and max <= 3.40282347 -%}
                TextField
            {% else -%}
                TextField
            {% endif -%}
        {% else -%}
            TextField
        {% endif -%}
    {% elif property.enum %}
        TextField
    {% elif macros::relation_is_one_to_many(property=property)=='true' or macros::relation_is_many_to_many(property=property)=='true'  -%}
        {% set relation = macros::get_relation(property=property) | plural | snake_case -%}
        TextField
    {% elif macros::relation_is_many_to_one(property=property)=='true' -%}
        {% set relation = macros::get_relation(property=property) -%}
        ReferenceField reference="{{ relation | plural | kebab_case }}" label="{{ relation | pascal_case }}"
    {% else -%}
        TextField
    {% endif -%}
{% endfilter %}
{%- endmacro -%}

{%- macro is_read_only(property) -%}
{% if property and property.readOnly -%}
readOnly
{% endif -%}
{%- endmacro -%}

{%- macro get_input_field(property) -%}
{% filter trim %}
    {% if property.type and property.type == "string" -%}
        {% if property.format and property.format == "uuid" -%}
            TextInput
        {% elif property.format and property.format == "date-time" -%}
            TextInput
        {% elif property.format and property.format == "date" -%}
            TextInput
        {% elif property.format and property.format == "time" -%}
            TextInput
        {% else -%}
            TextInput
        {% endif -%}    
    {% elif property.type and property.type == "boolean" -%}
        TextInput
    {% elif property.type and property.type == "integer" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min and min >= 0 -%}
            {% if max and max <= 255 -%}
                TextInput
            {% elif max and max <= 65535 -%}
                TextInput
            {% elif max and max <= 4294967295 -%}
                TextInput
            {% else -%}
                TextInput
            {% endif -%}
        {% else -%}
            {% if max and max <= 127 -%}
                TextInput
            {% elif max and max <= 32767 -%}
                TextInput
            {% elif max and max <= 2147483647 -%}
                TextInput
            {% else -%}
                TextInput
            {% endif -%}
        {% endif -%}
    {% elif property.type and property.type == "number" -%}
        {% set min = property.minimum or property.exclusiveMinimum -%}
        {% set max = property.maximum or property.exclusiveMaximum -%}
        {% if min or max -%}
            {% if min and min >= -3.40282347 and max and max <= 3.40282347 -%}
                TextInput
            {% else -%}
                TextInput
            {% endif -%}
        {% else -%}
            TextInput
        {% endif -%}
    {% elif property.enum %}
        SelectField choices={[
            {%- for enum in property.enum -%}
               { name: '{{ enum }}' }{%- if not loop.last -%},{% endif -%}
            {%- endfor -%}
            ]}
    {% elif property['x-relationship'] and property['$ref'] %}
        TextInput
    {% else -%}
        TextInput
    {% endif -%}
{% endfilter %}
{%- endmacro -%}


{%- macro get_all_properties_by_name(entity) -%}
{%- set_global properties = [] -%}
{% for name,property in entity.properties -%}
    {% if macros::relation_is_one_to_many(property=property)=='true' or macros::relation_is_many_to_many(property=property)=='true'  -%}
    {% continue -%}
    {% endif -%}
    {% if macros::relation_is_many_to_one(property=property)=='true'  -%}
    {% set relation = macros::get_relation(property=property) | camel_case | trim -%}
    {% set name = relation ~ " { id }" -%}
    {% endif -%}
    {%- set_global properties = properties | concat(with=name) -%}
{% endfor -%}
{{ properties | join(sep=" ") }}
{%- endmacro -%}