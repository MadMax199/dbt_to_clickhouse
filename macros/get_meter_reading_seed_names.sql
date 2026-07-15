{% macro get_meter_reading_seed_names() %}
    {#-
        Durchsucht den dbt-Graphen nach allen Seeds, deren Name ausschließlich aus
        Ziffern besteht (z.B. "100101", "7069411"). Das sind die 1.298 Messwertdateien,
        die jeweils nach der Household_ID benannt sind. So muss die Liste nicht manuell
        gepflegt werden, wenn neue Haushalte hinzukommen oder entfernt werden.
    -#}
    {% set seed_names = [] %}
    {% for node in graph.nodes.values() %}
        {% if node.resource_type == 'seed' and modules.re.match('^[0-9]+$', node.name) %}
            {% do seed_names.append(node.name) %}
        {% endif %}
    {% endfor %}
    {{ return(seed_names) }}
{% endmacro %}
