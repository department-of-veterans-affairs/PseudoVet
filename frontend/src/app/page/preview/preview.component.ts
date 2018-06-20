import { Component, OnInit } from '@angular/core';
import { AppConfig } from '../../config';
import { DataService } from '../../services/data.service';
import { Router } from '@angular/router';
import { UtilService } from '../../services/util.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-preview',
  templateUrl: './preview.component.html',
  styleUrls: ['./preview.component.scss']
})
export class PreviewComponent implements OnInit {

  previewData: any = {
    studyProfile: {},
    morbiditiesData: [],
  };
  configurationSave = false;
  configurationClose = false;
  menu = [
    { name: 'Dashboard', url: '/dashboard', subname: '' },
    { name: 'Create configuration', url: '/configuration/create', subname: '' },
    { name: 'Load configuration:', url: '/load', subname: 'Preview', active: true }
  ];

  constructor (private dataService: DataService,
               private toastr: ToastrService,
               private router: Router) {
    try {
      const configuration = JSON.parse(localStorage.getItem(AppConfig.PREVIEW_CONFIG_KEY));
      this.previewData = configuration;
    } catch (e) {
      this.noConfigurationError();
    }
  }

  ngOnInit (): void {
  }

  /**
   * no configuration data found in localStorage
   */
  noConfigurationError () {
    this.toastr.error('No any configuration can review');
  }

  /**
   * according backend rule get the gender
   * @param rule the backend rule string
   * @return {string} the gender
   */
  getGenderAndAgeFromExclusions (rule) {
    const gender = UtilService.getGenderFromExclusions(rule);
    const age = UtilService.getAgeFromExclusions(rule);
    return gender + (age.length === 0 ? '' : `,${age}`);
  }

  /**
   * on edit button click
   */
  onEditClick () {
    localStorage.setItem(AppConfig.EDIT_CONFIG_KEY, JSON.stringify(this.previewData));
    this.router.navigate(['/configuration/preview/edit']);
  }

  /**
   * on save button click
   */
  onSaveClick () {
    const configuration = this.previewData;
    delete configuration['name'];
    this.dataService.createOrUpdatedatasetConfiguration(configuration).then(res => {
      this.configurationSave = true;
    }).catch(err => {
      console.error(err);
      this.toastr.error(err.message);
    });
  }
}
