/**
 * TypeScript Type Definitions for Presentation App
 */

export type SlideType = 'cover' | 'plan' | 'chapter' | 'content' | 'image' | 'split' | 'quote' | 'thanks' | 'table' | 'paragraph' | 'mixed' | 'schema' | 'timeline' | 'quality' | 'tech-carousel';

export type AnimationType = 'fade' | 'slide' | 'zoom' | 'flip';

export type DesignTemplate = 'design1' | 'design2' | 'design3' | 'design4' | 'design5';

export interface DesignInfo {
  id: DesignTemplate;
  name: string;
  description: string;
  primaryColor: string;
  previewGradient: string;
}

export interface SlideContent {
  title?: string;
  subtitle?: string;
  content?: string;
  bulletPoints?: string[];
  imageUrl?: string;
  quote?: string;
  author?: string;
  chapterNumber?: number;
  date?: string;
  contact?: string;
  email?: string;
  website?: string;
  message?: string;
  items?: string[]; // For plan slide
  tableData?: {
    headers: string[];
    rows: string[][];
    rowImages?: (string | null)[]; // Optional images for each row
    rowDetails?: Array<{
      description: string;
      avantages?: string[];
      limites: string[];
      technologies?: string[];
      cout?: string;
      reference: string;
    }>;
  };
  // New types for paragraph
  paragraphs?: string[];
  // New types for mixed (paragraph + items)
  intro?: string;
  conclusion?: string;
  // New types for schema
  schema?: {
    type: 'architecture' | 'tree' | 'flow' | 'detailed-tree';
    description?: string;
    nodes?: Array<{ id: string; label: string; position: string }>;
    tree?: string;
    services?: Array<{
      name: string;
      icon: string;
      tech: string;
      color: string;
      structure: string[];
    }>;
  };
  // New types for timeline
  timeline?: string[];
  // New types for quality
  checklist?: string[];
  kpis?: {
    headers: string[];
    rows: string[][];
  };
  // New types for tech-carousel
  technologies?: Array<{
    domain: string;
    name: string;
    icon: string;
    color: string;
    description?: string;
  }>;
}

export interface Slide {
  id: string;
  type: SlideType;
  content: SlideContent;
  background?: string; // Tailwind gradient class or color
  animation?: AnimationType;
  order?: number; // Slide order in presentation
}

export interface Presentation {
  id: string;
  title: string;
  description?: string;
  slides: Slide[];
  createdAt: Date;
  updatedAt: Date;
  theme?: PresentationTheme;
  design?: DesignTemplate; // Selected design template
  author?: string;
}

export interface PresentationTheme {
  primaryColor: string;
  secondaryColor: string;
  fontFamily: string;
  backgroundColor: string;
}

export interface PresentationState {
  currentSlide: number;
  isFullscreen: boolean;
  isPlaying: boolean;
}

export interface NavigationControl {
  onNext: () => void;
  onPrevious: () => void;
  onSlideSelect: (index: number) => void;
  currentSlide: number;
  totalSlides: number;
}
