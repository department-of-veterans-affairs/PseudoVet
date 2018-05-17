import types
import json
import jinja2
from randomizer import custom_filters
from config import TEMPLATES_DIR, CCDA_TPL_FILENAME, FHIR_TPL_FILENAME
from .fhir_json2xml import process_node

'''
Wrapper for Jinja2 templating engine
See http://jinja.pocoo.org/docs/2.10 for more details on the Jinja engine
'''


class Renderer:
    def __init__(self):
        """
        Initialize class instance by loading template and custom filters
        """
        self.template_files = {
            'CCDA': CCDA_TPL_FILENAME,
            'FHIR-XML': FHIR_TPL_FILENAME,
            'FHIR-JSON': FHIR_TPL_FILENAME
        }
        self.environment = jinja2.Environment(loader=jinja2.FileSystemLoader(TEMPLATES_DIR))

        # load filters defined in custom_filters
        for a in dir(custom_filters):
            if isinstance(custom_filters.__dict__.get(a), types.FunctionType):
                self.environment.filters[a] = custom_filters.__dict__.get(a)

        self.templates = {}
        for key in self.template_files:
            self.templates[key] = self.environment.get_template(self.template_files[key])

    def render(self, context, output_format):
        """
        Render template using the provided context
        :param context: the value context
        :param output_format:  the outputFormat string
        :return: the rendered string
        """

        tpl = self.templates.get(output_format, None)
        if tpl is None:
            raise Exception('cannot found {0} template, please check.'.format(output_format))
        content = tpl.render(context)

        if output_format == 'FHIR-XML':
            node_str_arr = ['<?xml version="1.0" encoding="UTF-8"?>', ]
            process_node(node_str_arr, json.loads(content), 0)
            content = '\n'.join(node_str_arr)
        elif output_format == 'FHIR-JSON':
            content = json.dumps(json.loads(content), indent=2)
        return content
