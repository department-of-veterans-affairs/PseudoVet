import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { NgModule } from '@angular/core';

// app routing
import { RoutesModule } from './routes/routes/routes.module';

import { AppComponent } from './app.component';
import { HeaderComponent } from './components/header/header.component';
import { DashboardComponent } from './page/dashboard/dashboard.component';
import { DataService } from './services/data.service';
import { HttpClientModule } from '@angular/common/http';
import { ModalComponent } from './components/modal/modal.component';
import { ProgressComponent } from './components/progress/progress.component';
import { LoadConfigurationComponent } from './page/load-configuration/load-configuration.component';
import { DragNdropDirective } from './directive/drag-ndrop.directive';
import { PreviewComponent } from './page/preview/preview.component';
import { ConfigurationComponent } from './page/configuration/configuration.component';
import { MultiSelectComponent } from './components/multi-select/multi-select.component';
import { PercentagePipe } from './pipe/percentage.pipe';
import { PercentageDirective } from './directive/percentage.directive';
import { NumberPipe } from './pipe/number.pipe';
import { NumberDirective } from './directive/number.directive';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { ToastrModule } from 'ngx-toastr';
import { NgProgressModule } from '@ngx-progressbar/core';
import { NgProgressHttpModule } from '@ngx-progressbar/http';


@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,
    DashboardComponent,
    ModalComponent,
    ProgressComponent,
    LoadConfigurationComponent,
    DragNdropDirective,
    PreviewComponent,
    ConfigurationComponent,
    MultiSelectComponent,
    PercentageDirective,
    NumberDirective,
    NumberPipe,
    PercentagePipe
  ],
  imports: [
    HttpClientModule,
    BrowserModule,
    RoutesModule,
    BrowserAnimationsModule,
    ToastrModule.forRoot({
      positionClass: 'toast-bottom-left',
      timeOut: 5000, // 5 seconds
      closeButton: true,
    }),
    NgProgressModule.forRoot(),
    NgProgressHttpModule,
    FormsModule,
  ],
  providers: [
    NumberPipe,
    PercentagePipe,
    DataService
  ],
  bootstrap: [AppComponent]
})
export class AppModule {
}
