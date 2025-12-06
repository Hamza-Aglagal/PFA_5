import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-toast',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="toast-container">
      @for (toast of notificationService.activeToasts(); track toast.id) {
        <div class="toast" [class]="'toast-' + toast.type" (click)="dismiss(toast.id)">
          <div class="toast-icon">
            @switch (toast.type) {
              @case ('success') { <span>✓</span> }
              @case ('error') { <span>✕</span> }
              @case ('warning') { <span>⚠</span> }
              @case ('info') { <span>ℹ</span> }
              @default { <span>📢</span> }
            }
          </div>
          <div class="toast-content">
            <strong>{{ toast.title }}</strong>
            <p>{{ toast.message }}</p>
          </div>
          <button class="toast-close" (click)="dismiss(toast.id); $event.stopPropagation()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
          <div class="toast-progress"></div>
        </div>
      }
    </div>
  `,
  styles: [`
    .toast-container {
      position: fixed;
      bottom: var(--space-6);
      right: var(--space-6);
      z-index: 9999;
      display: flex;
      flex-direction: column-reverse;
      gap: var(--space-3);
      max-width: 380px;
      width: 100%;
      
      @media (max-width: 480px) {
        left: var(--space-4);
        right: var(--space-4);
        bottom: var(--space-4);
        max-width: none;
      }
    }
    
    .toast {
      display: flex;
      align-items: flex-start;
      gap: var(--space-3);
      padding: var(--space-4);
      background: var(--bg-card);
      border: 1px solid var(--border-primary);
      border-radius: var(--radius-xl);
      box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
      cursor: pointer;
      animation: slideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      position: relative;
      overflow: hidden;
      
      &:hover {
        transform: translateX(-4px);
      }
    }
    
    :host-context(body.light-mode) .toast {
      background: #ffffff;
      box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
    }
    
    .toast-icon {
      width: 32px;
      height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: var(--radius-lg);
      font-size: 1rem;
      flex-shrink: 0;
    }
    
    .toast-success .toast-icon {
      background: rgba(34, 197, 94, 0.15);
      color: var(--success-500);
    }
    
    .toast-error .toast-icon {
      background: rgba(239, 68, 68, 0.15);
      color: var(--danger-500);
    }
    
    .toast-warning .toast-icon {
      background: rgba(245, 158, 11, 0.15);
      color: var(--warning-500);
    }
    
    .toast-info .toast-icon {
      background: rgba(59, 130, 246, 0.15);
      color: var(--primary-500);
    }
    
    .toast-content {
      flex: 1;
      min-width: 0;
      
      strong {
        display: block;
        font-size: 0.875rem;
        color: var(--text-primary);
        margin-bottom: 2px;
      }
      
      p {
        margin: 0;
        font-size: 0.8125rem;
        color: var(--text-secondary);
        line-height: 1.4;
      }
    }
    
    .toast-close {
      width: 24px;
      height: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      background: none;
      border: none;
      color: var(--text-muted);
      cursor: pointer;
      border-radius: var(--radius-md);
      transition: all var(--transition-fast);
      flex-shrink: 0;
      
      svg {
        width: 14px;
        height: 14px;
      }
      
      &:hover {
        background: var(--bg-input);
        color: var(--text-primary);
      }
    }
    
    .toast-progress {
      position: absolute;
      bottom: 0;
      left: 0;
      height: 3px;
      background: var(--primary-500);
      animation: progress 4s linear forwards;
    }
    
    .toast-success .toast-progress { background: var(--success-500); }
    .toast-error .toast-progress { background: var(--danger-500); }
    .toast-warning .toast-progress { background: var(--warning-500); }
    
    @keyframes slideIn {
      from {
        opacity: 0;
        transform: translateX(100%);
      }
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }
    
    @keyframes progress {
      from { width: 100%; }
      to { width: 0%; }
    }
  `]
})
export class ToastComponent {
  // Inject notification service
  notificationService = inject(NotificationService);

  dismiss(id: string) {
    this.notificationService.dismiss(id);
  }
}
