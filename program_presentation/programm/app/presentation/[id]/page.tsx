'use client';

import { useParams } from 'next/navigation';
import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { getPresentationById } from '../../../lib/presentations';
import { Presentation, Slide } from '../../../lib/types';
import SlideRenderer from '../../components/SlideRenderer';
import NavigationControls from '../../components/NavigationControls';
import SlideIndicator from '../../components/SlideIndicator';
import FullscreenButton from '../../components/FullscreenButton';

export default function PresentationPage() {
  const params = useParams();
  const id = params?.id as string;
  
  const [presentation, setPresentation] = useState<Presentation | null>(null);
  const [currentSlideIndex, setCurrentSlideIndex] = useState(0);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [direction, setDirection] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    console.log('Loading presentation with ID:', id);
    if (id) {
      try {
        const pres = getPresentationById(id);
        console.log('Found presentation:', pres);
        setPresentation(pres || null);
      } catch (error) {
        console.error('Error loading presentation:', error);
      } finally {
        setIsLoading(false);
      }
    } else {
      setIsLoading(false);
    }
  }, [id]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight' || e.key === ' ') {
        e.preventDefault();
        handleNext();
      } else if (e.key === 'ArrowLeft') {
        e.preventDefault();
        handlePrevious();
      } else if (e.key === 'Escape') {
        exitFullscreen();
      } else if (e.key === 'f' || e.key === 'F') {
        toggleFullscreen();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentSlideIndex, presentation]);

  const handleNext = useCallback(() => {
    if (presentation && currentSlideIndex < presentation.slides.length - 1) {
      setDirection(1);
      setCurrentSlideIndex((prev) => prev + 1);
    }
  }, [currentSlideIndex, presentation]);

  const handlePrevious = useCallback(() => {
    if (currentSlideIndex > 0) {
      setDirection(-1);
      setCurrentSlideIndex((prev) => prev - 1);
    }
  }, [currentSlideIndex]);

  const handleSlideSelect = useCallback((index: number) => {
    setDirection(index > currentSlideIndex ? 1 : -1);
    setCurrentSlideIndex(index);
  }, [currentSlideIndex]);

  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen();
      setIsFullscreen(true);
    } else {
      document.exitFullscreen();
      setIsFullscreen(false);
    }
  };

  const exitFullscreen = () => {
    if (document.fullscreenElement) {
      document.exitFullscreen();
      setIsFullscreen(false);
    }
  };

  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };

    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, []);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 to-gray-800 
                    flex items-center justify-center">
        <div className="text-center">
          <div className="text-white text-2xl mb-4">Loading presentation...</div>
          <div className="text-white/60">ID: {id}</div>
        </div>
      </div>
    );
  }

  if (!presentation) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 to-gray-800 
                    flex items-center justify-center">
        <div className="text-center">
          <div className="text-white text-2xl mb-4">Presentation not found</div>
          <div className="text-white/60 mb-6">ID: {id}</div>
          <a 
            href="/"
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 
                     transition-colors inline-block"
          >
            Back to Home
          </a>
        </div>
      </div>
    );
  }

  const currentSlide = presentation.slides[currentSlideIndex];

  // Professional fluid slide transitions - Fade + Slide
  const slideVariants = {
    enter: (direction: number) => ({
      x: direction > 0 ? '5%' : '-5%',
      opacity: 0,
      scale: 0.98,
    }),
    center: {
      zIndex: 1,
      x: 0,
      opacity: 1,
      scale: 1,
    },
    exit: (direction: number) => ({
      zIndex: 0,
      x: direction < 0 ? '5%' : '-5%',
      opacity: 0,
      scale: 0.98,
    }),
  };

  return (
    <div className="relative w-full h-screen overflow-hidden bg-black">
      {/* Main Slide Area */}
      <AnimatePresence initial={false} custom={direction} mode="wait">
        <motion.div
          key={currentSlideIndex}
          custom={direction}
          variants={slideVariants}
          initial="enter"
          animate="center"
          exit="exit"
          transition={{
            x: { type: 'tween', ease: 'easeInOut', duration: 0.4 },
            opacity: { duration: 0.4, ease: 'easeInOut' },
            scale: { duration: 0.4, ease: 'easeInOut' },
          }}
          className="absolute inset-0"
        >
          <SlideRenderer slide={currentSlide} />
        </motion.div>
      </AnimatePresence>

      {/* Navigation Controls */}
      <motion.div 
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2 z-50"
        animate={{
          scale: isFullscreen ? 0.75 : 1,
          opacity: isFullscreen ? 0.3 : 1,
        }}
        whileHover={{ opacity: 1, scale: isFullscreen ? 0.85 : 1 }}
        transition={{ duration: 0.2 }}
      >
        <NavigationControls
          onNext={handleNext}
          onPrevious={handlePrevious}
          onSlideSelect={handleSlideSelect}
          currentSlide={currentSlideIndex}
          totalSlides={presentation.slides.length}
          isFullscreen={isFullscreen}
        />
      </motion.div>

      {/* Slide Indicator */}
      <motion.div 
        className="absolute bottom-8 right-8 z-50"
        animate={{
          scale: isFullscreen ? 0.7 : 1,
          opacity: isFullscreen ? 0.2 : 1,
        }}
        whileHover={{ opacity: 1 }}
        transition={{ duration: 0.2 }}
      >
        <SlideIndicator
          current={currentSlideIndex + 1}
          total={presentation.slides.length}
        />
      </motion.div>

      {/* Fullscreen Button */}
      <motion.div 
        className="absolute top-8 right-8 z-50"
        animate={{
          scale: isFullscreen ? 0.7 : 1,
          opacity: isFullscreen ? 0.2 : 1,
        }}
        whileHover={{ opacity: 1 }}
        transition={{ duration: 0.2 }}
      >
        <FullscreenButton
          isFullscreen={isFullscreen}
          onToggle={toggleFullscreen}
        />
      </motion.div>

      {/* Presentation Title (Top Left) */}
      <motion.div
        initial={{ opacity: 0, x: -50 }}
        animate={{ 
          opacity: isFullscreen ? 0.2 : 1, 
          x: 0,
          scale: isFullscreen ? 0.75 : 1
        }}
        whileHover={{ opacity: 1 }}
        transition={{ delay: 0.5, duration: 0.2 }}
        className="absolute top-8 left-8 z-40"
      >
        <div className="bg-white/95 backdrop-blur-md px-6 py-3 rounded-full 
                      border-2 border-gray-200 shadow-xl">
          <p className="text-gray-800 text-sm font-medium">
            {presentation.title}
          </p>
        </div>
      </motion.div>

      {/* Progress Bar */}
      <motion.div 
        className="absolute top-0 left-0 w-full z-50"
        animate={{
          height: isFullscreen ? '0.25rem' : '0.375rem',
          opacity: isFullscreen ? 0.3 : 1,
        }}
        transition={{ duration: 0.2 }}
      >
        <div className="h-full bg-gray-200/50">
          <motion.div
            className="h-full bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 shadow-lg"
            initial={{ width: 0 }}
            animate={{
              width: `${((currentSlideIndex + 1) / presentation.slides.length) * 100}%`,
            }}
            transition={{ duration: 0.3 }}
          />
        </div>
      </motion.div>
    </div>
  );
}
