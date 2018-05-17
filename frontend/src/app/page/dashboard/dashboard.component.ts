import { Component, OnInit } from '@angular/core';
import { DataService } from '../../services/data.service';
import { UtilService } from '../../services/util.service';
import { Router } from '@angular/router';
import { AppConfig } from '../../config';
import { ToastrService } from 'ngx-toastr';
import { saveAs } from 'file-saver/FileSaver';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {
  dashboardData: any = {};
  datasets: any = null;
  configurations: any = null;
  inProgressDatasets: any = [];
  deleteInProgress = false;
  deleteInProgressObj: any = {};
  deleteGenerated = false;
  deleteGeneratedObj: any = {};
  exportGenerated = false;
  exportGeneratedObj: any = {};
  reGenerated = false;
  reGeneratedObj: any = {};
  generated = false;
  generatedObj: any = {};
  deleteConfigItem = false;
  deleteConfigObj: any = {};
  menu = [
    { name: 'Dashboard', url: '/dashboard', subname: '', active: true },
    { name: 'Create configuration', url: '/configuration/create', subname: '' },
    { name: 'Load configuration', url: '/load', subname: '' }
  ];

  constructor (private dataService: DataService,
               private toastr: ToastrService,
               private router: Router) {
    this.fetchConfigurations();
    this.fetchDatasets();
  }

  /**
   * get PatientsAndRadio label for table row
   * @param item the configuration item
   * @return {string} the label
   */
  getPatientsAndRadioLabel(item) {
    return `${item.numberOfPatients.toLocaleString()} / ${(item.maleRatio
      || (item.femaleRatio ? 100 - item.femaleRatio : 0))}:${(item.femaleRatio
      || (item.maleRatio ? 100 - item.maleRatio : 0))}`;
  }
  /**
   * fetch configurations
   */
  fetchConfigurations () {
    this.dataService.getConfigurations().then(res => {
      this.configurations = res;
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.error ? err.error.message : err.message);
    });
  }

  /**
   * fetch datasets
   */
  fetchDatasets () {
    this.dataService.getDatasets().then(res => {
      this.datasets = res;
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.error ? err.error.message : err.message);
    });
  }

  /**
   * Remove items form in progress
   * @param index - item index
   */
  removeInProgressItem (index) {
    this.deleteInProgress = true;
    const name = this.dashboardData.inprogress[index].name;
    const progress = this.dashboardData.inprogress[index].progress;
    this.deleteInProgressObj = {
      index,
      name,
      progress
    };
  }

  /**
   * Remove In Progress Item
   */
  removeInProgress () {
    this.dashboardData.inprogress.splice(this.deleteInProgressObj.index, 1);
    this.deleteInProgress = false;
  }

  /**
   * remove items from generated
   * @param index - item index
   */
  removeGeneratedItem (index) {
    this.deleteGenerated = true;
    const dataset = this.datasets[index];
    const configObj = dataset.configuration;
    this.deleteGeneratedObj = {
      index,
      name: configObj.title,
      text: UtilService.getDescriptionByBackendConfig(configObj),
      datasetName : dataset.datasetName
    };
  }

  /**
   * on delete generated item
   */
  onRemoveGeneratedItem () {
    this.dataService.deleteDatasetByTitle(this.deleteGeneratedObj.datasetName).then(res => {
      this.datasets.splice(this.deleteGeneratedObj.index, 1);
      this.deleteGenerated = false;
      this.toastr.success('Dataset remove succeed');
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.error ? err.error.message : err.message);
    });
  }

  /**
   * remove items from config
   * @param index - item index
   */
  removeConfigItem (index) {
    this.deleteConfigItem = true;
    const configObj = this.configurations[index];
    this.deleteConfigObj = {
      index,
      name: configObj.title,
      text: UtilService.getDescriptionByBackendConfig(configObj)
    };
  }

  /**
   * on delete config item
   */
  onRemoveConfigItem () {
    this.dataService.deleteConfigByTitle(this.deleteConfigObj.name).then(res => {
      this.configurations.splice(this.deleteConfigObj.index, 1);
      this.deleteConfigItem = false;
      this.toastr.success('Dataset Configuration remove succeeded');
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.error ? err.error.message : err.message);
    });
  }

  /**
   * Export generated item
   * @param index - item index
   */
  exportGeneratedItem (index) {
    this.exportGenerated = true;
    const name = this.dashboardData.generated[index].name;
    let text = this.dashboardData.generated[index].demographics;
    const split = text.split('/');
    split[1] = split[1] + ' patients';
    split[2] = split[2] + ' male-female ratio';
    text = split.join('/');
    this.exportGeneratedObj = {
      index,
      name,
      text
    };
  }

  /**
   * Generate Dataset Items
   * @param index - item index
   */
  generateDataset (index) {
    this.generated = true;
    const configObj = this.configurations[index];
    this.generatedObj = {
      index,
      name: configObj.title,
      text: UtilService.getDescriptionByBackendConfig(configObj)
    };
  }

  /**
   * on generated button click
   */
  onGeneratedDataset () {
    this.dataService.generateDatasets(this.generatedObj.name).then(res => {
      this.generated = false;
      this.generatedObj = null;
      this.fetchDatasets();
      this.toastr.success('Dataset Generate succeed');
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.error ? err.error.message : err.message);
    });
  }

  /**
   * Regenerate Items
   * @param index - item index
   */
  reGeneratedItem (index) {
    this.reGenerated = true;
    const dataset = this.datasets[index];
    const configObj = dataset.configuration;
    this.reGeneratedObj = {
      index,
      name: configObj.title,
      text: UtilService.getDescriptionByBackendConfig(configObj)
    };
  }

  /**
   * on re generated button click
   */
  onReGeneratedDataset () {
    this.dataService.generateDatasets(this.reGeneratedObj.name).then(res => {
      this.reGenerated = false;
      this.reGeneratedObj = null;
      this.fetchDatasets();
      this.toastr.success('Dataset reGenerate succeed');
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.error ? err.error.message : err.message);
    });
  }

  /**
   * on edit configuration
   */
  onConfigurationEditClick (index) {
    const configObj = this.configurations[index];
    localStorage.setItem(AppConfig.EDIT_CONFIG_KEY, JSON.stringify(configObj));
    this.router.navigate(['/configuration/dashboard/edit']);
  }

  /**
   * on dataset edit configuration
   */
  onDatsetEditConfigClick (index) {
    const configObj = this.datasets[index].configuration;
    localStorage.setItem(AppConfig.EDIT_CONFIG_KEY, JSON.stringify(configObj));
    this.router.navigate(['/configuration/dashboard/edit']);
  }

  /**
   * on export button click
   */
  onExportClick (index) {
    const configObj = this.configurations[index];
    this.exportGenerated = true;
    this.exportGeneratedObj = {
      index,
      name: configObj.title,
      text: UtilService.getDescriptionByBackendConfig(configObj)
    };
    const blob = new Blob([JSON.stringify(configObj, null, 2)], { type: 'text/plain' });
    saveAs(blob, configObj.title + '.json');
  }


  ngOnInit () {
  }

}
