import { Injectable, signal } from '@angular/core';

// Toast interface
export interface Toast {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title: string;
  message: string;
  duration?: number;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  // Active toasts list
  private toasts = signal<Toast[]>([]);

  // Expose toasts as readonly
  activeToasts = this.toasts.asReadonly();

  constructor() {
    console.log('NotificationService: Initialized');
  }

  /**
   * Show a toast notification
   */
  show(type: Toast['type'], title: string, message: string, duration: number = 4000): void {
    const id = this.generateId();
    const toast: Toast = { id, type, title, message, duration };

    console.log(`NotificationService: Showing ${type} toast - ${title}`);

    // Add toast to list
    this.toasts.update(toasts => [...toasts, toast]);

    // Auto dismiss after duration
    if (duration > 0) {
      setTimeout(() => this.dismiss(id), duration);
    }
  }

  /**
   * Show success toast
   */
  success(title: string, message: string, duration?: number): void {
    this.show('success', title, message, duration);
  }

  /**
   * Show error toast
   */
  error(title: string, message: string, duration?: number): void {
    this.show('error', title, message, duration);
  }

  /**
   * Show warning toast
   */
  warning(title: string, message: string, duration?: number): void {
    this.show('warning', title, message, duration);
  }

  /**
   * Show info toast
   */
  info(title: string, message: string, duration?: number): void {
    this.show('info', title, message, duration);
  }

  /**
   * Dismiss a toast by id
   */
  dismiss(id: string): void {
    this.toasts.update(toasts => toasts.filter(t => t.id !== id));
  }

  /**
   * Dismiss all toasts
   */
  dismissAll(): void {
    this.toasts.set([]);
  }

  /**
   * Generate unique id using crypto API (secure random)
   */
  private generateId(): string {
    // Use crypto.randomUUID() for secure random ID generation
    // This satisfies SonarQube security requirements
    return crypto.randomUUID();
  }
}
