'use client';

import { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface TechCarouselSlideProps {
  slide: Slide;
}

export default function TechCarouselSlide({ slide }: TechCarouselSlideProps) {
  const { title, technologies } = slide.content;
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isMounted, setIsMounted] = useState(false);

  // Fix hydration: only render particles after mount
  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Stable particle positions to avoid hydration mismatch
  const particlePositions = useMemo(() => {
    return Array.from({ length: 6 }, (_, i) => ({
      left: `${10 + i * 15}%`,
      top: `${20 + (i % 3) * 20}%`,
      color: ['#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4', '#10b981', '#f97316'][i],
      delay: i * 0.3,
    }));
  }, []);

  // Auto-advance every 4 seconds
  useEffect(() => {
    if (!technologies || technologies.length === 0) return;
    
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % technologies.length);
    }, 4000);

    return () => clearInterval(interval);
  }, [technologies]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyPress = (e: KeyboardEvent) => {
      if (!technologies) return;
      
      if (e.key === 'ArrowRight' || e.key.toLowerCase() === 'd') {
        setCurrentIndex((prev) => (prev + 1) % technologies.length);
      } else if (e.key === 'ArrowLeft' || e.key.toLowerCase() === 'a') {
        setCurrentIndex((prev) => (prev - 1 + technologies.length) % technologies.length);
      }
    };

    window.addEventListener('keydown', handleKeyPress);
    return () => window.removeEventListener('keydown', handleKeyPress);
  }, [technologies]);

  if (!technologies || technologies.length === 0) {
    return (
      <div className={`relative w-full h-full flex items-center justify-center ${slide.background || 'bg-white'}`}>
        <p className="text-gray-500">No technologies to display</p>
      </div>
    );
  }

  const currentTech = technologies[currentIndex];

  return (
    <div className={`relative w-full h-full flex flex-col items-center justify-center p-12 ${slide.background || 'bg-white'} overflow-hidden`}>
      {/* Title */}
      <motion.div
        initial={{ opacity: 0, y: -30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="text-center mb-12"
      >
        <h1 className="text-5xl font-bold bg-gradient-to-r from-amber-600 via-orange-600 to-red-600 bg-clip-text text-transparent">
          {title}
        </h1>
      </motion.div>

      {/* All Technologies in One Line - Small Size */}
      <div className="relative w-full max-w-6xl mb-16">
        <div className="flex items-center justify-center gap-4">
          {technologies.map((tech, index) => {
            const isActive = index === currentIndex;
            
            return (
              <motion.div
                key={index}
                animate={{
                  scale: isActive ? 0 : 1,
                  opacity: isActive ? 0 : 0.7,
                  y: isActive ? -50 : 0,
                }}
                transition={{
                  duration: 0.5,
                  ease: "easeInOut",
                }}
                onClick={() => setCurrentIndex(index)}
                className={`cursor-pointer hover:opacity-100 transition-opacity ${
                  isActive ? 'pointer-events-none' : ''
                }`}
              >
                <div className={`bg-gradient-to-br ${tech.color} rounded-xl p-3 w-24 shadow-lg`}>
                  <div className="text-3xl text-center mb-1">
                    {tech.icon}
                  </div>
                  <p className="text-white text-[10px] font-bold text-center leading-tight">
                    {tech.name}
                  </p>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>

      {/* Large Active Technology - Center */}
      <div className="relative w-full max-w-5xl h-96 flex items-center justify-center">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentIndex}
            initial={{ scale: 0, opacity: 0, y: -100 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0, opacity: 0, y: 100 }}
            transition={{
              duration: 0.6,
              ease: [0.43, 0.13, 0.23, 0.96],
            }}
            className="absolute inset-0 flex items-center justify-center"
          >
            {/* Technology Card */}
            <motion.div
              animate={{
                boxShadow: [
                  '0 20px 60px rgba(0,0,0,0.15)',
                  '0 25px 80px rgba(0,0,0,0.25)',
                  '0 20px 60px rgba(0,0,0,0.15)',
                ],
              }}
              transition={{ duration: 2, repeat: Infinity }}
              className={`relative bg-gradient-to-br ${currentTech.color} rounded-3xl p-12 w-full max-w-3xl`}
            >
              {/* Icon - Large and Animated */}
              <motion.div
                animate={{
                  scale: [1, 1.1, 1],
                  rotate: [0, 5, -5, 0],
                }}
                transition={{
                  duration: 2,
                  repeat: Infinity,
                  ease: "easeInOut",
                }}
                className="text-9xl text-center mb-6 filter drop-shadow-2xl"
              >
                {currentTech.icon}
              </motion.div>

              {/* Domain Label */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="text-center mb-4"
              >
                <span className="inline-block bg-white/20 backdrop-blur-sm px-6 py-2 rounded-full text-white font-semibold text-lg uppercase tracking-wider">
                  {currentTech.domain}
                </span>
              </motion.div>

              {/* Technology Name */}
              <motion.h2
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="text-5xl font-bold text-white text-center mb-4"
              >
                {currentTech.name}
              </motion.h2>

              {/* Description */}
              {currentTech.description && (
                <motion.p
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.4 }}
                  className="text-white/90 text-center text-xl font-medium"
                >
                  {currentTech.description}
                </motion.p>
              )}

              {/* Decorative Lines */}
              <motion.div
                initial={{ scaleX: 0 }}
                animate={{ scaleX: 1 }}
                transition={{ delay: 0.5, duration: 0.6 }}
                className="absolute top-8 left-1/2 transform -translate-x-1/2 h-1 w-32 bg-white/40 rounded-full origin-center"
              />
              <motion.div
                initial={{ scaleX: 0 }}
                animate={{ scaleX: 1 }}
                transition={{ delay: 0.5, duration: 0.6 }}
                className="absolute bottom-8 left-1/2 transform -translate-x-1/2 h-1 w-32 bg-white/40 rounded-full origin-center"
              />
            </motion.div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Progress Indicators */}
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
        className="mt-8 flex items-center gap-3"
      >
        {technologies.map((_, index) => (
          <motion.button
            key={index}
            onClick={() => setCurrentIndex(index)}
            animate={{
              scale: index === currentIndex ? 1.5 : 1,
              backgroundColor: index === currentIndex 
                ? 'rgb(249, 115, 22)' // orange-500
                : 'rgb(209, 213, 219)', // gray-300
            }}
            whileHover={{ scale: 1.3 }}
            transition={{ duration: 0.3 }}
            className="w-3 h-3 rounded-full cursor-pointer shadow-lg"
            aria-label={`Go to technology ${index + 1}`}
          />
        ))}
      </motion.div>

      {/* Counter Display */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1 }}
        className="absolute bottom-12 left-1/2 transform -translate-x-1/2 text-gray-600 font-semibold text-lg"
      >
        {currentIndex + 1} / {technologies.length}
      </motion.div>

      {/* Keyboard Hints */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.2 }}
        className="absolute bottom-12 right-12 flex items-center gap-4 text-gray-500 text-sm"
      >
        <div className="flex items-center gap-2">
          <kbd className="px-3 py-1.5 bg-white rounded-lg shadow border border-gray-300 font-mono font-semibold">
            ←
          </kbd>
          <kbd className="px-3 py-1.5 bg-white rounded-lg shadow border border-gray-300 font-mono font-semibold">
            →
          </kbd>
          <span className="ml-1">Navigate</span>
        </div>
      </motion.div>

      {/* Auto-play indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.4 }}
        className="absolute top-12 right-12 flex items-center gap-2 text-gray-500 text-sm"
      >
        <motion.div
          animate={{ scale: [1, 1.2, 1], opacity: [0.5, 1, 0.5] }}
          transition={{ duration: 4, repeat: Infinity }}
          className="w-2 h-2 bg-orange-500 rounded-full"
        />
        <span>Auto-play 4s</span>
      </motion.div>

      {/* Floating Particles in Background */}
      {isMounted && particlePositions.map((particle, i) => (
        <motion.div
          key={i}
          animate={{
            x: [0, 30, -30, 0],
            y: [0, -40, 40, 0],
            opacity: [0.2, 0.5, 0.2],
          }}
          transition={{
            duration: 5,
            repeat: Infinity,
            delay: particle.delay,
            ease: "easeInOut",
          }}
          className="absolute w-20 h-20 rounded-full blur-2xl pointer-events-none"
          style={{
            background: `linear-gradient(135deg, ${particle.color}40, transparent)`,
            left: particle.left,
            top: particle.top,
          }}
        />
      ))}
    </div>
  );
}
