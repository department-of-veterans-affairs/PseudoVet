import { Directive, ElementRef, HostListener, OnInit } from '@angular/core';
import { PercentagePipe } from '../pipe/percentage.pipe';

@Directive({
  selector: '[appPercentage]'
})
export class PercentageDirective implements OnInit {

  private el: any;

  constructor (private elementRef: ElementRef,
               private percentagePipe: PercentagePipe) {
    this.el = this.elementRef.nativeElement;

  }

  ngOnInit () {
    this.el.value = this.percentagePipe.transform(this.el.value);
  }

  @HostListener('focus', ['$event.target.value'])
  onFocus (value) {
    this.el.value = this.percentagePipe.parse(value);
  }

  @HostListener('blur', ['$event.target.value'])
  onBlur (value) {
    this.el.value = this.percentagePipe.transform(value);
  }


}
