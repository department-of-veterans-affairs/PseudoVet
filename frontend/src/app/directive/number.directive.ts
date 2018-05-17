import { Directive, ElementRef, HostListener, OnInit, Output, EventEmitter, Input } from '@angular/core';
import { NumberPipe } from '../pipe/number.pipe';

@Directive({
  selector: '[appNumber]'
})
export class NumberDirective implements OnInit {
  private el: any;
  @Output() ngModelChange: EventEmitter<any> = new EventEmitter();
  @Input() roundOff = true;
  @Input() mustFormat = true;
  @Input() maxVal: number;
  @Input() minVal: number;

  constructor (private elementRef: ElementRef,
               private numberPipe: NumberPipe) {
    this.el = this.elementRef.nativeElement;

  }

  ngOnInit () {
    this.el.value = this.numberPipe.transform(this.el.value);
  }

  @HostListener('focus', ['$event.target.value'])
  onFocus (value) {
    const result = this.numberPipe.parse(value, this.roundOff, this.mustFormat, this.minVal, this.maxVal);
    this.ngModelChange.emit(result);
  }

  @HostListener('blur', ['$event.target.value'])
  onBlur (value) {
    const result = this.numberPipe.transform(value, this.roundOff, this.mustFormat, this.minVal, this.maxVal);
    this.ngModelChange.emit(result);
  }
}
