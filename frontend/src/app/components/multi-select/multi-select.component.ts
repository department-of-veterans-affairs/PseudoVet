import { Component, ElementRef, EventEmitter, HostListener, Input, OnInit, Output } from '@angular/core';

@Component({
  selector: 'app-multi-select',
  templateUrl: './multi-select.component.html',
  styleUrls: ['./multi-select.component.scss']
})
export class MultiSelectComponent implements OnInit {

  @Input() options = [];
  @Input() selectedOptions = [];
  copyOfSelectedOptions = [];
  @Output() add: EventEmitter<any> = new EventEmitter;
  open = false;

  constructor (private _eref: ElementRef) {
  }

  ngOnInit () {
    this.copyOfSelectedOptions = [...this.selectedOptions];
  }

  /**
   * on dropdown action
   */
  openDropDown () {
    this.open = !this.open;
    this.copyOfSelectedOptions = [...this.selectedOptions];
  }

  /**
   * is option selected
   */
  isChecked (option) {
    return this.copyOfSelectedOptions.filter(item => item.icd10Code === option.icd10Code && item.name === option.name).length > 0;
  }

  /**
   * Remove selected Item
   * @param e - event
   * @param index - index of the item to be removed
   */
  removeItem (e, index) {
    this.selectedOptions.splice(index, 1);
    this.add.emit(this.selectedOptions);
    this.copyOfSelectedOptions.splice(index, 1);
    e.stopPropagation();
  }

  /**
   * hide drop down
   */
  @HostListener('document:click', ['$event'])
  hideDropDown (event) {
    if (!this._eref.nativeElement.contains(event.target)) {
      this.open = false;
    }
  }

  /**
   * Toggle select
   * @param e - event
   * @param text - selected item text
   */
  toggleItem (e, text) {
    if (this.copyOfSelectedOptions.indexOf(text) === -1) {
      this.copyOfSelectedOptions.push(text);
    } else {
      this.copyOfSelectedOptions.splice(this.copyOfSelectedOptions.indexOf(text), 1);
    }
    e.stopPropagation();
  }

  /**
   * clear selections
   */
  clear () {
    this.selectedOptions = [];
    this.add.emit(this.selectedOptions);
    this.open = false;
  }

  /**
   * add selected Items
   */
  addSelected () {
    this.selectedOptions = [...this.copyOfSelectedOptions];
    this.add.emit(this.copyOfSelectedOptions);
    this.open = false;
  }
}
