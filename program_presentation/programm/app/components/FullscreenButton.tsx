'use client';

import { motion } from 'framer-motion';

interface FullscreenButtonProps {
  isFullscreen: boolean;
  onToggle: () => void;
}

export default function FullscreenButton({
  isFullscreen,
  onToggle,
}: FullscreenButtonProps) {
  return (
    <motion.button
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.5 }}
      onClick={onToggle}
      className="bg-white/95 backdrop-blur-lg p-4 rounded-full 
                border-2 border-gray-200 hover:border-blue-400
                transition-all duration-300 shadow-xl group"
      title={isFullscreen ? 'Exit Fullscreen (ESC)' : 'Fullscreen (F)'}
    >
      {isFullscreen ? (
        <svg
          className="w-6 h-6 text-gray-700 group-hover:scale-110 group-hover:text-blue-600 transition-all"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M9 9V4.5M9 9H4.5M9 9L3.75 3.75M15 9h4.5M15 9V4.5M15 9l5.25-5.25M9 15v4.5M9 15H4.5M9 15l-5.25 5.25M15 15h4.5M15 15v4.5m0-4.5l5.25 5.25"
          />
        </svg>
      ) : (
        <svg
          className="w-6 h-6 text-gray-700 group-hover:scale-110 group-hover:text-blue-600 transition-all"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5v-4m0 4h-4m4 0l-5-5"
          />
        </svg>
      )}
    </motion.button>
  );
}
