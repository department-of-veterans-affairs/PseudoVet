import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

import 'rxjs/add/operator/share';

@Injectable()
export class DataService {
  private _warErasData = null;

  constructor (private http: HttpClient) {
  }


  /**
   * get all warEras and cache those data
   * @return {any} the promise with data
   */
  getWarEras () {
    if (this._warErasData !== null) {
      return Promise.resolve(this._warErasData);
    } else {
      return this.http.get(`${environment.baseUri}/warEras`).toPromise()
        .then(res => {
          this._warErasData = res;
          return this._warErasData;
        });
    }
  }

  /**
   * get morbidities by war name
   * @param {string} warName
   * @return {Array} the morbidities
   */
  getMorbiditiesByWarName (warName: string) {
    return this.http.get(`${environment.baseUri}/morbidities?warEra=${warName}`).toPromise();
  }

  /**
   * generate dataset by title
   * @param {string} title the config title
   */
  generateDatasets (title: string) {
    return this.http.put(`${environment.baseUri}/generateDatasets?title=${title}`, {}).toPromise();
  }

  /**
   * create new or update exist configuration
   * @param configuration the configuration json entity
   */
  createOrUpdatedatasetConfiguration (configuration) {
    return this.http.put(`${environment.baseUri}/datasetConfigurations`, configuration).toPromise();
  }

  /**
   * get datasets
   */
  getDatasets () {
    return this.http.get(`${environment.baseUri}/datasets`).toPromise();
  }

  /**
   * delete dataset by title
   * @param {string} title the data title
   */
  deleteDatasetByTitle (title: string) {
    return this.http.delete(`${environment.baseUri}/datasets?title=${title}`).toPromise();
  }

  /**
   * get configurations
   */
  getConfigurations () {
    return this.http.get(`${environment.baseUri}/datasetConfigurations`).toPromise();
  }

  /**
   * delete config by title
   * @param {string} title the config title
   */
  deleteConfigByTitle (title: string) {
    return this.http.delete(`${environment.baseUri}/datasetConfigurations?title=${title}`).toPromise();
  }

}
