import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'number'
})
export class NumberPipe implements PipeTransform {

  transform (value: any, roundOff?: boolean, mustFormat?: boolean, minVal?: number, maxVal?: number, blank?: boolean ): any {
    value = (value || '').toString();
    value = value.replace(/,/g , '');
    let v = parseFloat(value);
    if (isNaN(v) || v < 0) {
      if (blank) {
        return '';
      }
      value = '0';
      if (minVal) {
        value = minVal.toString();
      }
    } else {
      if (minVal && v < minVal) {
        v = minVal;
      }
      if (maxVal && maxVal > 0 && v > maxVal) {
        v = maxVal;
      }
      if (roundOff && roundOff === true) {
        if (v > 2147483647) { // MAX INT
          value = '2147483647';
        } else {
          value = Math.round(v).toString();
        }
      } else {
        value = v.toString();
      }
    }
    if (mustFormat && mustFormat === true) {
      value = value.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }
    return value;
  }

  parse (value: string, roundOff?: boolean, mustFormat?: boolean, minVal?: number, maxVal?: number, blank?: boolean ): string {
    value = (value || '').toString();
    value = value.replace(/,/g , '');
    let v = parseFloat(value);
    if (isNaN(v) || v < 0) {
      if (blank) {
        return '';
      }
      value = '0';
      if (minVal) {
        value = minVal.toString();
      }
    } else {
      if (minVal && v < minVal) {
        v = minVal;
      }
      if (maxVal && maxVal > 0 && v > maxVal) {
        v = maxVal;
      }
      if (roundOff && roundOff === true) {
        value = Math.round(v).toString();
      } else {
        value = v.toString();
      }
    }
    if (mustFormat && mustFormat === true) {
      value = value.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }
    return value;
  }

}
