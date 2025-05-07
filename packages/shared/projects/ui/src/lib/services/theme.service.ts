import { effect, Injectable, signal } from '@angular/core';
import { Theme } from '../model/interface';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {

  constructor() { 
    effect(() => {
      const theme = this.currentTheme();
      document.body.classList.remove(...themes.map((theme) => `${theme.id}-theme`));
      document.body.classList.add(`${theme.id}-theme`);
    });
  }

  private readonly currentTheme = signal<Theme>(themes[0]);
  public get themes() {
    return themes;
  }
  
  public setTheme(id:string) {
    const theme = themes.find((theme) => theme.id === id);
    if (theme) {
      this.currentTheme.set(theme);
    }
  }
}

const themes: Theme[] = [
  { 
    id: 'bears',
    iconUrl: 'https://images.seeklogo.com/logo-png/20/1/chicago-bears-logo-png_seeklogo-203479.png',
    primary: '#0B162A',
    displayName: 'Bears',
  },
  {
    id: 'blackhawks',
    iconUrl: 'https://images.seeklogo.com/logo-png/22/1/chicago-blackhawks-logo-png_seeklogo-223478.png',
    primary: '#C8102E',
    displayName: 'Blackhawks',
  }
]
