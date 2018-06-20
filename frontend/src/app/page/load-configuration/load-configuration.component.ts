import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { DataService } from '../../services/data.service';
import { Router } from '@angular/router';
import { AppConfig } from '../../config';
import { UtilService } from '../../services/util.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-load-configuration',
  templateUrl: './load-configuration.component.html',
  styleUrls: ['./load-configuration.component.scss']
})
export class LoadConfigurationComponent implements OnInit {

  @ViewChild('selectedFile') selectedFile: ElementRef;

  fileSelected = false;
  fileSave = false;
  menu = [
    { name: 'Dashboard', url: '/dashboard', subname: '' },
    { name: 'Create configuration', url: '/configuration/create', subname: '' },
    { name: 'Load configuration', url: '/load', subname: '', active: true }
  ];
  /* the selectd file preview dialog object*/
  filePreviewObject = { description: '', error: false, msg: '', name: '' };
  configuration: any = null;

  constructor (private dataservice: DataService,
               private toastr: ToastrService,
               private router: Router) {
  }

  ngOnInit () {
  }

  /**
   * File dropped
   * @param files - selected files
   */
  onFilesChange (files) {
    if (files && files.length > 0) {
      const file = files[0];
      this.parseConfigurationFile(file);
    }
  }

  /**
   * parse configuration file that selected
   */
  parseConfigurationFile (file) {
    const reader = new FileReader();
    const previewObj = {
      name: file.name,
      description: 'N/A',
      error: false,
      msg: 'Configuration file has been loaded. Preview, edit or load this file into database.',
    };

    if (this.getFileExtension(file.name) !== 'json') {
      previewObj.error = true;
      previewObj.msg = 'Configuration file must be json format.';
    }

    if (file.size > 1024 * 1024) {
      previewObj.error = true;
      previewObj.msg = 'Configuration file must be less than 1 Mb.';
    }

    if (previewObj.error) {
      this.fileSelected = true;
      this.filePreviewObject = previewObj;
    } else {
      reader.onload = () => {
        const content = reader.result;
        try {
          const configObj = JSON.parse(content);
          previewObj.description = UtilService.getDescriptionByBackendConfig(configObj);
          this.configuration = this.convertToBackendConfiguration(configObj);
        } catch (e) {
          previewObj.error = true;
          previewObj.msg = 'Configuration file is invalid, please check your file';
        }
        this.filePreviewObject = previewObj;
        this.fileSelected = true;
      };
      reader.readAsText(file);
    }
    this.selectedFile.nativeElement.value = null;
  }

  /**
   * get file extension name
   * @param filename the file name
   * @return the file extension
   */
  getFileExtension (filename) {
    return filename.split('.').pop().toLowerCase();
  }

  /**
   * File selected
   * @param event - event
   */
  fileChange (event) {
    const fileList: FileList = event.target.files;
    if (fileList.length > 0) {
      this.parseConfigurationFile(fileList[0]);
    }
  }

  /**
   * Show File Dialog
   */
  showBrowseDlg () {
    this.selectedFile.nativeElement.click();
  }

  /**
   * on save button click
   */
  onSaveClick () {
    this.dataservice.createOrUpdatedatasetConfiguration(this.configuration).then(res => {
      this.fileSelected = false;
      this.fileSave = true;
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.error ? err.error.message : err.message);
    });
  }

  /**
   * frontend configuration convert to backend configuration, then send this config object to server
   * @param loadedConfig the uploaded config object
   * @return the backend config object
   */
  convertToBackendConfiguration (loadedConfig) {
    const configObject = {
      title: loadedConfig.title.trim(),
      numberOfPatients:  isNaN(parseInt(loadedConfig.numberOfPatients, 10)) ? 0 : parseInt(loadedConfig.numberOfPatients, 10),
      maleRatio: isNaN(parseFloat(loadedConfig.maleRatio)) ? 0 : parseInt(loadedConfig.maleRatio, 10),
      femaleRatio: isNaN(parseFloat(loadedConfig.femaleRatio)) ? 0 : parseInt(loadedConfig.femaleRatio, 10),
      morbiditiesData: loadedConfig.morbiditiesData.map(m => ({
        icd10Code: m.icd10Code,
        name: m.name,
        exclusionRules: m.exclusionRules,
        numberOfEncounters: isNaN(parseFloat(m.numberOfEncounters)) ? 0 : parseFloat(m.numberOfEncounters),
        percentOfPopulationWithDiagnosisRisk: isNaN(parseFloat(m.percentOfPopulationWithDiagnosisRisk))
                                                                ? 0 : parseFloat(m.percentOfPopulationWithDiagnosisRisk),
        percentOfProbabilityToAcquireDiagnosis: isNaN(parseFloat(m.percentOfProbabilityToAcquireDiagnosis))
                                                                ? 0 : parseFloat(m.percentOfProbabilityToAcquireDiagnosis)})),
      relatedConditionsData: loadedConfig.relatedConditionsData ? loadedConfig.relatedConditionsData.map(m => ({
        icd10Code: m.icd10Code,
        name: m.name,
        exclusionRules: m.exclusionRules,
        numberOfEncounters: isNaN(parseFloat(m.numberOfEncounters)) ? 0 : parseFloat(m.numberOfEncounters),
        percentOfPopulationWithDiagnosisRisk: isNaN(parseFloat(m.percentOfPopulationWithDiagnosisRisk))
                                                                ? 0 : parseFloat(m.percentOfPopulationWithDiagnosisRisk),
        percentOfProbabilityToAcquireDiagnosis: isNaN(parseFloat(m.percentOfProbabilityToAcquireDiagnosis))
                                                                ? 0 : parseFloat(m.percentOfProbabilityToAcquireDiagnosis)})) : [],
      studyProfile: loadedConfig.studyProfile,
      outputFormat: loadedConfig.outputFormat,
      year: loadedConfig.year
    };
    if (!configObject.year) {
      configObject.year = new Date().getUTCFullYear();
    }
    return configObject;
  }

  /**
   * on preview button click
   */
  onPreviewClick () {
    this.configuration.name = this.filePreviewObject.name;
    localStorage.setItem(AppConfig.PREVIEW_CONFIG_KEY, JSON.stringify(this.configuration));
    this.router.navigate(['preview']);
  }
}
