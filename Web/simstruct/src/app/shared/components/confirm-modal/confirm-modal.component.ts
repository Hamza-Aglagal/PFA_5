import { Component, signal, Injectable } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject } from 'rxjs';

export interface ConfirmModalConfig {
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  type?: 'danger' | 'warning' | 'info' | 'success';
  icon?: string;
}

export interface ActionModalConfig {
  title: string;
  subtitle?: string;
  actions: ActionItem[];
  type?: 'default' | 'danger';
}

export interface ActionItem {
  id: string;
  label: string;
  icon: string;
  description?: string;
  type?: 'default' | 'danger' | 'primary';
}

@Injectable({
  providedIn: 'root'
})
export class ModalService {
  private confirmSubject = new Subject<boolean>();
  private actionSubject = new Subject<string | null>();
  
  showConfirm = signal(false);
  showActions = signal(false);
  confirmConfig = signal<ConfirmModalConfig | null>(null);
  actionConfig = signal<ActionModalConfig | null>(null);

  confirm(config: ConfirmModalConfig): Promise<boolean> {
    this.confirmConfig.set(config);
    this.showConfirm.set(true);
    
    return new Promise((resolve) => {
      const subscription = this.confirmSubject.subscribe(result => {
        subscription.unsubscribe();
        resolve(result);
      });
    });
  }

  closeConfirm(result: boolean): void {
    this.showConfirm.set(false);
    this.confirmSubject.next(result);
  }

  showActionMenu(config: ActionModalConfig): Promise<string | null> {
    this.actionConfig.set(config);
    this.showActions.set(true);
    
    return new Promise((resolve) => {
      const subscription = this.actionSubject.subscribe(result => {
        subscription.unsubscribe();
        resolve(result);
      });
    });
  }

  closeActionMenu(actionId: string | null): void {
    this.showActions.set(false);
    this.actionSubject.next(actionId);
  }
}

@Component({
  selector: 'app-confirm-modal',
  standalone: true,
  imports: [CommonModule],
  template: `
    <!-- Confirmation Modal -->
    @if (modalService.showConfirm()) {
      <div class="modal-overlay" (click)="onOverlayClick($event)">
        <div class="modal-container confirm-modal" [class]="modalService.confirmConfig()?.type || 'info'">
          <div class="modal-icon">
            @switch (modalService.confirmConfig()?.type) {
              @case ('danger') {
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <line x1="15" y1="9" x2="9" y2="15"/>
                  <line x1="9" y1="9" x2="15" y2="15"/>
                </svg>
              }
              @case ('warning') {
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                  <line x1="12" y1="9" x2="12" y2="13"/>
                  <line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
              }
              @case ('success') {
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                  <polyline points="22 4 12 14.01 9 11.01"/>
                </svg>
              }
              @default {
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <line x1="12" y1="16" x2="12" y2="12"/>
                  <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
              }
            }
          </div>
          
          <h2 class="modal-title">{{ modalService.confirmConfig()?.title }}</h2>
          <p class="modal-message">{{ modalService.confirmConfig()?.message }}</p>
          
          <div class="modal-actions">
            <button class="btn btn-cancel" (click)="modalService.closeConfirm(false)">
              {{ modalService.confirmConfig()?.cancelText || 'Cancel' }}
            </button>
            <button class="btn btn-confirm" [class]="modalService.confirmConfig()?.type || 'info'" (click)="modalService.closeConfirm(true)">
              {{ modalService.confirmConfig()?.confirmText || 'Confirm' }}
            </button>
          </div>
        </div>
      </div>
    }

    <!-- Action Menu Modal -->
    @if (modalService.showActions()) {
      <div class="modal-overlay" (click)="onOverlayClick($event)">
        <div class="modal-container action-modal" [class]="modalService.actionConfig()?.type || 'default'">
          <div class="action-header">
            <h2 class="modal-title">{{ modalService.actionConfig()?.title }}</h2>
            @if (modalService.actionConfig()?.subtitle) {
              <p class="modal-subtitle">{{ modalService.actionConfig()?.subtitle }}</p>
            }
            <button class="close-btn" (click)="modalService.closeActionMenu(null)">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="6" x2="6" y2="18"/>
                <line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>
          
          <div class="action-list">
            @for (action of modalService.actionConfig()?.actions; track action.id) {
              <button 
                class="action-item" 
                [class]="action.type || 'default'"
                (click)="modalService.closeActionMenu(action.id)"
              >
                <span class="action-icon" [innerHTML]="action.icon"></span>
                <div class="action-content">
                  <span class="action-label">{{ action.label }}</span>
                  @if (action.description) {
                    <span class="action-description">{{ action.description }}</span>
                  }
                </div>
                <svg class="action-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="9 18 15 12 9 6"/>
                </svg>
              </button>
            }
          </div>
        </div>
      </div>
    }
  `,
  styles: [`
    .modal-overlay {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.6);
      backdrop-filter: blur(4px);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 10000;
      animation: fadeIn 0.2s ease-out;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    @keyframes slideUp {
      from { 
        opacity: 0;
        transform: translateY(20px) scale(0.95);
      }
      to { 
        opacity: 1;
        transform: translateY(0) scale(1);
      }
    }

    .modal-container {
      background: var(--bg-card, #1e293b);
      border-radius: 20px;
      padding: 32px;
      max-width: 420px;
      width: 90%;
      animation: slideUp 0.3s ease-out;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
    }

    // Confirm Modal Styles
    .confirm-modal {
      text-align: center;

      .modal-icon {
        width: 72px;
        height: 72px;
        margin: 0 auto 20px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        
        svg {
          width: 36px;
          height: 36px;
        }
      }

      &.danger .modal-icon {
        background: linear-gradient(135deg, #fecaca 0%, #fca5a5 100%);
        svg { stroke: #dc2626; }
      }

      &.warning .modal-icon {
        background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
        svg { stroke: #d97706; }
      }

      &.success .modal-icon {
        background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
        svg { stroke: #059669; }
      }

      &.info .modal-icon {
        background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
        svg { stroke: #2563eb; }
      }
    }

    .modal-title {
      font-size: 1.375rem;
      font-weight: 700;
      color: var(--text-primary, #f1f5f9);
      margin: 0 0 12px;
    }

    .modal-message {
      font-size: 0.9375rem;
      color: var(--text-secondary, #94a3b8);
      margin: 0 0 28px;
      line-height: 1.6;
    }

    .modal-actions {
      display: flex;
      gap: 12px;

      .btn {
        flex: 1;
        padding: 14px 24px;
        border-radius: 12px;
        font-size: 0.9375rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        border: none;
      }

      .btn-cancel {
        background: var(--bg-input, #334155);
        color: var(--text-secondary, #94a3b8);

        &:hover {
          background: var(--bg-secondary, #475569);
        }
      }

      .btn-confirm {
        &.danger {
          background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
          color: white;
          &:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4); }
        }

        &.warning {
          background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
          color: white;
          &:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.4); }
        }

        &.success {
          background: linear-gradient(135deg, #10b981 0%, #059669 100%);
          color: white;
          &:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4); }
        }

        &.info {
          background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
          color: white;
          &:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4); }
        }
      }
    }

    // Action Menu Styles
    .action-modal {
      padding: 0;
      overflow: hidden;

      .action-header {
        padding: 24px 24px 16px;
        border-bottom: 1px solid var(--border-primary, #334155);
        position: relative;

        .close-btn {
          position: absolute;
          top: 16px;
          right: 16px;
          width: 32px;
          height: 32px;
          border-radius: 8px;
          background: var(--bg-input, #334155);
          border: none;
          color: var(--text-muted, #64748b);
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: all 0.2s ease;

          svg {
            width: 18px;
            height: 18px;
          }

          &:hover {
            background: var(--bg-secondary, #475569);
            color: var(--text-primary, #f1f5f9);
          }
        }
      }

      .modal-title {
        margin: 0;
        padding-right: 40px;
      }

      .modal-subtitle {
        font-size: 0.875rem;
        color: var(--text-muted, #64748b);
        margin: 8px 0 0;
      }

      .action-list {
        padding: 8px;
      }

      .action-item {
        width: 100%;
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px;
        background: transparent;
        border: none;
        border-radius: 12px;
        cursor: pointer;
        transition: all 0.2s ease;
        text-align: left;

        &:hover {
          background: var(--bg-input, #334155);

          .action-arrow {
            transform: translateX(4px);
            opacity: 1;
          }
        }

        &.danger {
          .action-icon, .action-label {
            color: #ef4444;
          }

          &:hover {
            background: rgba(239, 68, 68, 0.1);
          }
        }

        &.primary {
          .action-icon, .action-label {
            color: #3b82f6;
          }

          &:hover {
            background: rgba(59, 130, 246, 0.1);
          }
        }
      }

      .action-icon {
        width: 44px;
        height: 44px;
        border-radius: 12px;
        background: var(--bg-input, #334155);
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--text-primary, #f1f5f9);
        font-size: 1.25rem;
        flex-shrink: 0;
      }

      .action-content {
        flex: 1;
        min-width: 0;

        .action-label {
          display: block;
          font-size: 0.9375rem;
          font-weight: 600;
          color: var(--text-primary, #f1f5f9);
        }

        .action-description {
          display: block;
          font-size: 0.8125rem;
          color: var(--text-muted, #64748b);
          margin-top: 2px;
        }
      }

      .action-arrow {
        width: 20px;
        height: 20px;
        color: var(--text-muted, #64748b);
        opacity: 0;
        transition: all 0.2s ease;
        flex-shrink: 0;
      }
    }
  `]
})
export class ConfirmModalComponent {
  constructor(public modalService: ModalService) {}

  onOverlayClick(event: Event): void {
    if ((event.target as HTMLElement).classList.contains('modal-overlay')) {
      if (this.modalService.showConfirm()) {
        this.modalService.closeConfirm(false);
      }
      if (this.modalService.showActions()) {
        this.modalService.closeActionMenu(null);
      }
    }
  }
}
