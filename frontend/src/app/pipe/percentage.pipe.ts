import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'percentage'
})
export class PercentagePipe implements PipeTransform {

  transform (value: any, args?: any): any {
    value = (value || '').toString();
    value = value === '' ? '0' : value;
    const v = parseFloat(value);
    if (!isNaN(v)) {
      if (v > 100) {
        value = '100';
      }
    } else {
      value = '0';
    }
    return value.indexOf('%') === -1 ? value + '%' : value;
  }

  parse (value: string): string {
    value = (value || '').toString();
    value = value === '' ? '0' : value;
    const v = parseFloat(value);
    if (isNaN(v)) {
      value = '0';
    } else if (v > 100) {
      value = '100';
    }
    return value.indexOf('%') === -1 ? value + '%' : value;
  }

}
