'use client';

import { motion } from 'framer-motion';

interface NavigationControlsProps {
  onNext: () => void;
  onPrevious: () => void;
  onSlideSelect: (index: number) => void;
  currentSlide: number;
  totalSlides: number;
  isFullscreen: boolean;
}

export default function NavigationControls({
  onNext,
  onPrevious,
  onSlideSelect,
  currentSlide,
  totalSlides,
  isFullscreen,
}: NavigationControlsProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 50 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.5 }}
      className="flex items-center gap-4 bg-white/95 backdrop-blur-lg 
                px-6 py-4 rounded-full border-2 border-gray-200 shadow-2xl"
    >
      {/* Previous Button */}
      <button
        onClick={onPrevious}
        disabled={currentSlide === 0}
        className="p-3 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 
                 hover:from-blue-600 hover:to-purple-700
                 disabled:opacity-30 disabled:cursor-not-allowed disabled:from-gray-400 disabled:to-gray-500
                 transition-all duration-300 group shadow-lg"
      >
        <svg
          className="w-6 h-6 text-white group-hover:scale-110 transition-transform"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M15 19l-7-7 7-7"
          />
        </svg>
      </button>

      {/* Slide Counter */}
      <div className="flex items-center gap-2 px-4">
        <span className="text-gray-800 font-bold text-lg">
          {currentSlide + 1}
        </span>
        <span className="text-gray-500">/</span>
        <span className="text-gray-600 text-lg">{totalSlides}</span>
      </div>

      {/* Next Button */}
      <button
        onClick={onNext}
        disabled={currentSlide === totalSlides - 1}
        className="p-3 rounded-full bg-gradient-to-r from-blue-500 to-purple-600 
                 hover:from-blue-600 hover:to-purple-700
                 disabled:opacity-30 disabled:cursor-not-allowed disabled:from-gray-400 disabled:to-gray-500
                 transition-all duration-300 group shadow-lg"
      >
        <svg
          className="w-6 h-6 text-white group-hover:scale-110 transition-transform"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M9 5l7 7-7 7"
          />
        </svg>
      </button>

      {/* Divider */}
      <div className="w-px h-8 bg-gray-300 mx-2" />

      {/* Home Button */}
      <a
        href="/"
        className="p-3 rounded-full bg-gray-100 hover:bg-gray-200 
                 transition-all duration-300 group shadow-md"
      >
        <svg
          className="w-6 h-6 text-gray-700 group-hover:scale-110 transition-transform"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
          />
        </svg>
      </a>
    </motion.div>
  );
}
