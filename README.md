# PseudoVet
![PseudoVet Logo](https://github.com/VHAINNOVATIONS/PseudoVet/blob/master/branding/PseudoVet.png)
# VHA Innovation Project ID 407
Innovator/Architect: Will BC Collins IV
Project Manager/COR: Brian Stevenson

*For current progress see proof_of_concept folder.

## Introduction
PseudoVet is an automated patient data fabrication engine.  It’s goal is to provide a set of active synthetic patients that can be used for healthcare software development and testing for applications that are geared towards VA’s VistA and Enterprise Heath Management Platform (eHMP) through the Veterans Health Administrations’ (VHA) Future Technology Laboratory (FTL) a publically accessible development environment.  More information on the VHA Innovation Laboratory and FTL can be found here: http://vaftl.us

## Background
Development against real patient data unnecessarily exposes patient health information (PHI) and personally identifiable information (PII) and cannot be used by developers outside of the VA network.  Development against current fabricated data is not useful because the data sets are very old which require development teams to spend much time developing data sets to use in lieu of writing code.  Typical fabrication of patient data is typically of little or no medical relevance.  The development of a system that creates and updates synthetic patient data using a set of templates for various diagnosis would provide more relevant patient data for development that could be used both inside and outside of the VA network.  Development outside of the VA network is desirable as it allows more  collaboration with the Open Source community which is in-line with the VA’s Open Source Initiatives.

## Technical Overview
PseudoVet’s fabricated patient records are created by random selection of diagnosis data such as service connected disabilities, symptoms, and thereby provides more clinically relevant fabricated progress notes, laboratory data, as well as surgical procedures, discharge, and other ancillary data.  In addition to common clinical data related to specific diagnosis, PseudoVet also continuously schedules appointments, randomly no-shows patients, generate consults, means tests and other administrative activities that occur in a real patients record.

## Architectural Overview
The PseudoVet system is comprised of the following components:
- Core Reference Database (CRD) – A MongoDB database containing model and template data used for the automatic generation of synthetic patient data
- PseudoVet Interface (PI) - A web based application and services to support the generation of synthetic patient and supporting data
- PseudoVet Database – A database where all generated synthetic patient resides
- Automation Services - Back-end services that generate and continuously update synthetic patient data
- Client EHR System Integration – Integration routines for data synchronization between the PseudoVet system and external Electronic Health Record Systems (EHR’s)

# Building with Vagrant
PseudoVet can be build using the vagrant up command from the root of a cloned or downloaded repository.  You must have Vagrant Installed to use this command.

```
vagrant up
```
Once the build process completes, connect to the PseudoVet VM by issuing the following command:
```
vagrant ssh
```

The source will be located at /vagrant on the provisioned virtual machine

# Building with Vortex (under development)
Vortex allows provisioning with VirtualBox as well as AWS.  Since FTL is an AWS shop, it makes sense to provide a Vortex build.  To use Vortex, install Node.js as well as Vortex by issuing the following command:
```
sudo npm install -g vortex
```

The default provider is VirtualBox.
```
vortex up
```
To build the system for AWS EC2, you will need to copy vortex.sample.json to vortex.json and edit the Vortex configuration file entering your AWS account data.

```
vortex --provider=Amazon boot
```

*More information on Vortex can be found here: https://github.com/websecurify/node-vortex/ 

# Proof of Concept
See the proof_of_concept folder in the source for documentation on prerequisites, configuring, and running the scripts for that process.
