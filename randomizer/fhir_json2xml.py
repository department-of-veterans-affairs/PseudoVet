"""
FHIR json format is like xml, so this module for convert FHIR json/dict format to FHIR xml format string
"""


def get_indent(depth):
    """
    get indent
    :param depth: the node depth
    :return:
    """
    return ' ' * (depth * 2)


def append_node_prefix(str_arr, node, depth):
    """
    append node prefix to xml string arr
    :param str_arr: the xml node string arr
    :param node: the json node
    :param depth: the node depth
    :return: None
    """
    node_type = node.get('resourceType', None)
    if node_type is None:
        return
    suffix = '<{0} {1}>'.format(node_type, node_type == 'Bundle' and 'xmlns="http://hl7.org/fhir"' or '')
    str_arr.append(get_indent(depth) + suffix)


def append_node_suffix(str_arr, node, depth):
    """
    append node suffix to xml string arr
    :param str_arr: the xml node string arr
    :param node: the json node
    :param depth: the node depth
    :return: None
    """
    node_type = node.get('resourceType', None)
    if node_type is None:
        return
    str_arr.append(get_indent(depth) + '</{0}>'.format(node_type))


def append_value(str_arr, key, value, depth):
    """
    append xml value node to node string arr
    :param str_arr: the xml node string arr
    :param key: the xml node key
    :param value: the xml node value
    :param depth: the json node depth
    :return: None
    """
    v = value
    if type(value) is bool:
        v = str(value).lower()
    if key == 'div':
        str_arr.append(v)
    else:
        str_arr.append(get_indent(depth) + '<{0} value="{1}"/>'.format(key, v))


def process_node(str_arr, node, depth):
    """
    convert FHIR json/dict to xml node, and push it to node string arr
    this metho use dfs to parse json/dict, see https://en.wikipedia.org/wiki/Depth-first_search
    :param str_arr: the node string array
    :param node: the json node
    :param depth: the json node depth, 0 mean root node
    :return: None
    """
    append_node_prefix(str_arr, node, depth)
    new_depth = depth + 1
    for key in node.keys():
        if key in ['resourceType', 'url']:
            continue
        value = node[key]
        value_type = type(value)
        if value_type is list:
            for item in value:
                if type(item) is dict:
                    url = ''
                    if key == 'extension':
                        url = 'url="{0}"'.format(item['url'])

                    str_arr.append(get_indent(new_depth) + '<{0} {1}>'.format(key, url))
                    process_node(str_arr, item, new_depth)
                    str_arr.append(get_indent(new_depth) + '</{0}>'.format(key))
                else:
                    append_value(str_arr, key, value, new_depth)
        elif value_type is dict:
            str_arr.append(get_indent(new_depth) + '<{0}>'.format(key))
            process_node(str_arr, value, new_depth)
            str_arr.append(get_indent(new_depth) + '</{0}>'.format(key))

        else:
            append_value(str_arr, key, value, new_depth)
    append_node_suffix(str_arr, node, depth)
