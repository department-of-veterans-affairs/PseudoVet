import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';

@Component({
  selector: 'app-modal',
  templateUrl: './modal.component.html',
  styleUrls: ['./modal.component.scss']
})
export class ModalComponent implements OnInit {
  @Input() title: string;
  @Input() name: string;
  @Input() text: string;
  @Input() type: string;
  @Input() subtitle: string;
  @Input() progress: string = null;
  @Input() gender: string;
  @Input() age: string;
  @Input() genderModal = false;

  @Output() changeGender: EventEmitter<any> = new EventEmitter;
  @Output() changeAge: EventEmitter<any> = new EventEmitter;
  @Output() close: EventEmitter<any> = new EventEmitter;

  ngOnInit () {
  }

  /**
   * Set Gender
   * @param gender - Male/Female/None
   */
  selectGender (gender) {
    this.changeGender.emit(gender);
  }

  /**
   * age input
   * @param age the age value
   */
  ageInput (age) {
    this.changeAge.emit(age);
  }

  /**
   * Close modal
   */
  closeModal () {
    this.close.emit();
  }

}
