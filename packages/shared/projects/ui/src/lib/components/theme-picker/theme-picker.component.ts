import { NgOptimizedImage } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { MatMenuModule } from '@angular/material/menu';
import { MatIconButton } from '@angular/material/button';
import { MatIcon } from '@angular/material/icon';
import { ThemeService } from '../../services';
import { Theme } from '../../model/interface';

@Component({
  selector: 'app-theme-picker',
  imports: [
    MatMenuModule,
    NgOptimizedImage,
    MatIconButton,
    MatIcon
  ],
  templateUrl: './theme-picker.component.html',
  styleUrl: './theme-picker.component.scss'
})
export class ThemePickerComponent {
  private readonly themeService = inject(ThemeService);
  protected readonly size = 30;
  protected readonly themes = signal<Theme[]>([]);

  ngOnInit(): void {
    this.themes.set(this.themeService.themes);
  }
  
  protected setTheme(id:string) {
    this.themeService.setTheme(id);
  }

}
