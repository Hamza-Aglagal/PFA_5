'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface ParagraphSlideProps {
  slide: Slide;
}

export default function ParagraphSlide({ slide }: ParagraphSlideProps) {
  const { title, paragraphs } = slide.content;

  return (
    <div className={`relative w-full h-full flex items-center justify-center p-16 ${slide.background || 'bg-white'}`}>
      <div className="max-w-5xl w-full">
        {/* Title */}
        <motion.div
          initial={{ opacity: 0, y: -30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="mb-12"
        >
          <h1 className="text-5xl font-bold bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent mb-4">
            {title}
          </h1>
          <div className="h-1.5 w-32 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full"></div>
        </motion.div>

        {/* Paragraphs */}
        <div className="space-y-8">
          {paragraphs?.map((paragraph, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.5, delay: 0.2 + index * 0.15 }}
              className="relative"
            >
              <div className="absolute left-0 top-0 w-1.5 h-full bg-gradient-to-b from-blue-400 to-purple-400 rounded-full"></div>
              <p className="text-xl text-gray-700 leading-relaxed pl-8">
                {paragraph}
              </p>
            </motion.div>
          ))}
        </div>

        {/* Decorative Element */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="absolute bottom-16 right-16 w-32 h-32 bg-gradient-to-br from-blue-200/30 to-purple-200/30 rounded-full blur-2xl"
        ></motion.div>
      </div>
    </div>
  );
}
