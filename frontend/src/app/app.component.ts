import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {

  /**
   * Scroll top on active
   * @param wrapper
   */
  onActivate (wrapper) {
    wrapper.scrollTop = 0;
  }
}
