{% macro get_meter_reading_seed_names() %}
    {#-
        Durchsucht den dbt-Graphen nach allen Seeds, deren Name ausschließlich aus
        Ziffern besteht (z.B. "100101", "7069411"). Das sind die 1.298 Messwertdateien,
        die jeweils nach der Household_ID benannt sind. So muss die Liste nicht manuell
        gepflegt werden, wenn neue Haushalte hinzukommen oder entfernt werden.

        Wichtig: graph.nodes ist während der Parse-Phase (vor der eigentlichen
        Ausführung) noch nicht befüllt. Der execute-Guard verhindert, dass dbt
        beim reinen Parsen (z.B. vor "dbt seed") mit "'dict object' has no
        attribute 'nodes'" abbricht.
    -#}
    {% set seed_names = [] %}
    {% if execute %}
        {% for node in graph.nodes.values() %}
            {% if node.resource_type == 'seed' and modules.re.match('^[0-9]+$', node.name) %}
                {% do seed_names.append(node.name) %}
            {% endif %}
        {% endfor %}
    {% endif %}
    {{ return(seed_names) }}
{% endmacro %}