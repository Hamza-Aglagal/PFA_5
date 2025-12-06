'use client';

import { motion } from 'framer-motion';

interface SlideIndicatorProps {
  current: number;
  total: number;
}

export default function SlideIndicator({ current, total }: SlideIndicatorProps) {
  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.5 }}
      className="bg-white/95 backdrop-blur-lg px-6 py-3 rounded-full 
                border-2 border-gray-200 shadow-xl"
    >
      <div className="flex items-center gap-3">
        <svg
          className="w-5 h-5 text-blue-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
          />
        </svg>
        <span className="text-gray-800 font-bold text-lg">
          {current} / {total}
        </span>
      </div>
    </motion.div>
  );
}
