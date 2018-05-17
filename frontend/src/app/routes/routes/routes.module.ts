import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { DashboardComponent } from '../../page/dashboard/dashboard.component';
import { LoadConfigurationComponent } from '../../page/load-configuration/load-configuration.component';
import { PreviewComponent } from '../../page/preview/preview.component';
import { ConfigurationComponent } from '../../page/configuration/configuration.component';

const routes: Routes = [
  { path: 'dashboard', component: DashboardComponent },
  { path: 'load', component: LoadConfigurationComponent },
  { path: 'preview', component: PreviewComponent },
  { path: 'configuration/:page/:type', component: ConfigurationComponent },
  { path: 'configuration/:type', component: ConfigurationComponent },
  { path: '**', redirectTo: 'dashboard' },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})

export class RoutesModule {
}
