{%- macro get_field(property) -%}
{% filter trim %}
    {% if property.type and property.type == "string" -%}
        {% if property.format and property.format == "uuid" -%}
            TextField
        {% elif property.format and property.format == "date-time" -%}
            TextField
        {% elif property.format and property.format == "date" -%}
            TextField
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
    {% elif property['x-relationship'] and property['$ref'] %}
        TextField
    {% else -%}
        TextField
    {% endif -%}
{% endfilter %}
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
        TextInput
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
    {%- set_global properties = properties | concat(with=name) -%}
{% endfor -%}
{{ properties | join(sep=" ") }}
{%- endmacro -%}