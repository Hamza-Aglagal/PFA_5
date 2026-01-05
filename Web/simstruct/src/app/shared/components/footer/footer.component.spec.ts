import { describe, it, expect, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
import { FooterComponent } from './footer.component';

describe('FooterComponent', () => {
  let component: FooterComponent;
  let fixture: ComponentFixture<FooterComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FooterComponent],
      providers: [
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: { params: {}, queryParams: {} },
            params: of({}),
            queryParams: of({})
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(FooterComponent);
    component = fixture.componentInstance;
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should have current year', () => {
      expect(component.currentYear).toBe(new Date().getFullYear());
    });
  });

  describe('footer links', () => {
    it('should have product links', () => {
      expect(component.footerLinks.product).toBeDefined();
      expect(component.footerLinks.product.length).toBeGreaterThan(0);
    });

    it('should have resources links', () => {
      expect(component.footerLinks.resources).toBeDefined();
      expect(component.footerLinks.resources.length).toBeGreaterThan(0);
    });

    it('should have company links', () => {
      expect(component.footerLinks.company).toBeDefined();
      expect(component.footerLinks.company.length).toBeGreaterThan(0);
    });

    it('should have legal links', () => {
      expect(component.footerLinks.legal).toBeDefined();
      expect(component.footerLinks.legal.length).toBeGreaterThan(0);
    });

    it('should have Features link in product', () => {
      const features = component.footerLinks.product.find(l => l.label === 'Features');
      expect(features).toBeTruthy();
    });

    it('should have Simulation link', () => {
      const simulation = component.footerLinks.product.find(l => l.label === 'Simulation');
      expect(simulation).toBeTruthy();
      expect(simulation?.path).toBe('/simulation');
    });

    it('should have Documentation link', () => {
      const docs = component.footerLinks.resources.find(l => l.label === 'Documentation');
      expect(docs).toBeTruthy();
    });

    it('should have Privacy Policy link', () => {
      const privacy = component.footerLinks.legal.find(l => l.label === 'Privacy Policy');
      expect(privacy).toBeTruthy();
      expect(privacy?.path).toBe('/privacy');
    });

    it('should have Terms of Service link', () => {
      const terms = component.footerLinks.legal.find(l => l.label === 'Terms of Service');
      expect(terms).toBeTruthy();
    });
  });

  describe('social links', () => {
    it('should have social links', () => {
      expect(component.socialLinks).toBeDefined();
      expect(component.socialLinks.length).toBeGreaterThan(0);
    });

    it('should have GitHub link', () => {
      const github = component.socialLinks.find(l => l.icon === 'github');
      expect(github).toBeTruthy();
      expect(github?.url).toContain('github.com');
    });

    it('should have LinkedIn link', () => {
      const linkedin = component.socialLinks.find(l => l.icon === 'linkedin');
      expect(linkedin).toBeTruthy();
      expect(linkedin?.url).toContain('linkedin.com');
    });

    it('should have Twitter link', () => {
      const twitter = component.socialLinks.find(l => l.icon === 'twitter');
      expect(twitter).toBeTruthy();
    });

    it('should have YouTube link', () => {
      const youtube = component.socialLinks.find(l => l.icon === 'youtube');
      expect(youtube).toBeTruthy();
    });

    it('should have labels for all social links', () => {
      component.socialLinks.forEach(link => {
        expect(link.label).toBeDefined();
        expect(link.label.length).toBeGreaterThan(0);
      });
    });
  });

  describe('link structure', () => {
    it('should have path for all product links', () => {
      component.footerLinks.product.forEach(link => {
        expect(link.path).toBeDefined();
      });
    });

    it('should have label for all links', () => {
      const allLinks = [
        ...component.footerLinks.product,
        ...component.footerLinks.resources,
        ...component.footerLinks.company,
        ...component.footerLinks.legal
      ];
      
      allLinks.forEach(link => {
        expect(link.label).toBeDefined();
        expect(link.label.length).toBeGreaterThan(0);
      });
    });
  });
});
