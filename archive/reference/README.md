Core Reference Database (CRD)
-----------------------
The core reference data is a collection of data that is used to generate synthetic patient data from.

*In other words, this "CRD" data is NOT the synthetic data.  It is the collection of data USED TO CREATE synthetic data.

The intention is that the raw files in this folder can be used to create a database containing this data as well as other data put here.  The files in this folder are not exhaustive.  This is a work in progress.  Feel free to add other relevant reference data.

Crosswalking must be accomplished between various data concerns in order to map procedures, diagnosis, service connected disabilites, lab values, etc... to provide a means of building a realistic collarily of synthetic patient data.

Webservices would then be written that will expose this reference data for use in creating rich synthetic patient datasets.

This data is 'suggested' to be divided into the following reference data concerns however, if there is a better way to do this, please do so:

demographics

names
-----
- last names
- first names
- middle names
- suffixes

incomes
-------
- occupations
- incomes
- banks

identifiers
-----------
- date of birth
- social security numbers
- sexes
- heights
- weights

addresses
---------
- address line 1
- address line 2
- address cities
- address states
- address zip codes
- address counties

contact
-------
- email addresses
- next_of_kin
- home phone numbers
- mobile phone numbers
- work phone numbers
- aliases
- races
- languages

military
--------
- war eras
- military branches
- dates of services
- war era related diangosis
- service connected disabilities

family
------
- family members

medical record
--------------
- diagnosis
- procedures
- laboratory urinalysis values
- laboratory blood values
- laboratory radiology values
- disabilities
- dsm 5
- icd 10
- snowmed
- cpt codes
- formulary

crosswalk
---------
- crosswalk
