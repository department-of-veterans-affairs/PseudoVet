"""
Jinja2 custom filters used to parse the template files.
See http://jinja.pocoo.org/docs/2.10/api/#custom-filters for the
explanation and how to create new filters.

Methods in this file are automatically added to the Jinja2 environment
by class Renderer __init__ (see renderer.py).
"""

from datetime import timedelta
from random import randint


def lower_case(v):
    # convert to lower case
    if not v:
        return ''
    return v.lower()


def datetime_format(value, new_format='%Y%m%d%H%M'):
    return value.strftime(new_format)


def minus_random_days(value, min_days, max_days):
    # pick a random number of days to subtract
    days_to_subtract = randint(min_days, max_days)

    return value - timedelta(days=days_to_subtract)


def plus_random_days(value, min_days, max_days):
    # pick a random number of days to add
    days_to_add = randint(min_days, max_days)

    return value + timedelta(days=days_to_add)


def plus_random_years(value, min_years, max_years):
    # pick a random number of years to add
    years_to_add = randint(min_years, max_years)

    return value + timedelta(days=years_to_add * 365)
