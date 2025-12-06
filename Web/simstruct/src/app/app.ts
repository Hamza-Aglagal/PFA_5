import { Component, signal, OnInit, OnDestroy, Renderer2, inject } from '@angular/core';
import { RouterOutlet, Router, NavigationEnd } from '@angular/router';
import { NavbarComponent } from './shared/components/navbar/navbar.component';
import { FooterComponent } from './shared/components/footer/footer.component';
import { SidebarComponent } from './shared/components/sidebar/sidebar.component';
import { ToastComponent } from './shared/components/toast/toast.component';
import { ConfirmModalComponent } from './shared/components/confirm-modal/confirm-modal.component';
import { AuthService } from './core/services/auth.service';
import { filter, Subscription } from 'rxjs';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, NavbarComponent, FooterComponent, SidebarComponent, ToastComponent, ConfirmModalComponent],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit, OnDestroy {
  private renderer = inject(Renderer2);
  private router = inject(Router);
  authService = inject(AuthService);
  private routerSub!: Subscription;
  
  protected readonly title = signal('SimStruct - Civil Structure Stability Simulation');
  isSimulationPage = signal(false);
  isFullscreenPage = signal(false); // For pages that need full screen without navbar (simulation, chat)
  
  ngOnInit(): void {
    // Check for saved theme preference
    const savedTheme = localStorage.getItem('simstruct-theme');
    if (savedTheme === 'light') {
      this.renderer.addClass(document.body, 'light-mode');
    }
    
    // Watch for route changes to handle fullscreen pages
    this.routerSub = this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        const url = event.urlAfterRedirects;
        const isSimulation = url.includes('/simulation');
        const isChat = url.includes('/chat');
        
        this.isSimulationPage.set(isSimulation);
        this.isFullscreenPage.set(isSimulation || isChat);
        
        if (isSimulation || isChat) {
          this.renderer.addClass(document.body, 'simulation-fullscreen');
        } else {
          this.renderer.removeClass(document.body, 'simulation-fullscreen');
        }
      });
  }
  
  ngOnDestroy(): void {
    if (this.routerSub) {
      this.routerSub.unsubscribe();
    }
    this.renderer.removeClass(document.body, 'simulation-fullscreen');
  }
}
