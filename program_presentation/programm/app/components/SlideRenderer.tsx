'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../lib/types';
import CoverSlide from './slides/CoverSlide';
import ContentSlide from './slides/ContentSlide';
import PlanSlide from './slides/PlanSlide';
import TableSlide from './slides/TableSlide';
import SplitSlide from './slides/SplitSlide';
import ThanksSlide from './slides/ThanksSlide';
import ParagraphSlide from './slides/ParagraphSlide';
import MixedSlide from './slides/MixedSlide';
import SchemaSlide from './slides/SchemaSlide';
import TimelineSlide from './slides/TimelineSlide';
import QualitySlide from './slides/QualitySlide';
import TechCarouselSlide from './slides/TechCarouselSlide';

interface SlideRendererProps {
  slide: Slide;
}

export default function SlideRenderer({ slide }: SlideRendererProps) {
  const renderSlide = () => {
    switch (slide.type) {
      case 'cover':
        return <CoverSlide slide={slide} />;
      case 'plan':
        return <PlanSlide slide={slide} />;
      case 'content':
        return <ContentSlide slide={slide} />;
      case 'table':
        return <TableSlide slide={slide} />;
      case 'split':
        return <SplitSlide slide={slide} />;
      case 'thanks':
        return <ThanksSlide slide={slide} />;
      case 'paragraph':
        return <ParagraphSlide slide={slide} />;
      case 'mixed':
        return <MixedSlide slide={slide} />;
      case 'schema':
        return <SchemaSlide slide={slide} />;
      case 'timeline':
        return <TimelineSlide slide={slide} />;
      case 'quality':
        return <QualitySlide slide={slide} />;
      case 'tech-carousel':
        return <TechCarouselSlide slide={slide} />;
      default:
        return <ContentSlide slide={slide} />;
    }
  };

  return (
    <div className={`w-full h-full ${slide.background || 'bg-gradient-to-br from-gray-900 to-gray-800'}`}>
      {renderSlide()}
    </div>
  );
}
