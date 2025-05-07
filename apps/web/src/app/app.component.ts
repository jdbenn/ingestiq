import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ThemeService } from '@repo/shared/services';
import { MatToolbar } from '@angular/material/toolbar';
import { ThemePickerComponent } from '@repo/shared/components';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [
      RouterOutlet,
      MatToolbar,
      ThemePickerComponent
    ],
    templateUrl: './app.component.html',
    styleUrl: './app.component.scss'
})
export class AppComponent {
  private readonly themeService = inject(ThemeService);
}
