'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface MixedSlideProps {
  slide: Slide;
}

export default function MixedSlide({ slide }: MixedSlideProps) {
  const { title, intro, items, conclusion } = slide.content;

  return (
    <div className={`relative w-full h-full flex items-center justify-center p-16 ${slide.background || 'bg-white'}`}>
      <div className="max-w-6xl w-full">
        {/* Title */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-10"
        >
          <h1 className="text-6xl font-bold bg-gradient-to-r from-orange-600 via-amber-600 to-yellow-600 bg-clip-text text-transparent">
            {title}
          </h1>
        </motion.div>

        {/* Intro Paragraph */}
        {intro && (
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="mb-10"
          >
            <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-8 shadow-lg border-l-4 border-orange-500">
              <p className="text-2xl text-gray-800 font-medium leading-relaxed">
                {intro}
              </p>
            </div>
          </motion.div>
        )}

        {/* Items as Cards */}
        <div className="grid grid-cols-1 gap-6 mb-10">
          {items?.map((item, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, x: -100 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.5, delay: 0.4 + index * 0.1 }}
              className="group"
            >
              <div className="relative bg-gradient-to-r from-white to-orange-50 rounded-xl p-6 shadow-md hover:shadow-xl transition-all duration-300 border border-orange-200/50">
                <div className="absolute left-0 top-0 bottom-0 w-2 bg-gradient-to-b from-orange-400 to-amber-400 rounded-l-xl"></div>
                <div className="flex items-start gap-4 pl-4">
                  <div className="flex-shrink-0 w-8 h-8 bg-gradient-to-br from-orange-500 to-amber-500 rounded-full flex items-center justify-center text-white font-bold shadow-lg">
                    {index + 1}
                  </div>
                  <p className="text-lg text-gray-800 leading-relaxed flex-1 pt-1">
                    {item}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Conclusion */}
        {conclusion && (
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.8 }}
            className="mt-10"
          >
            <div className="bg-gradient-to-r from-orange-100 via-amber-100 to-yellow-100 rounded-2xl p-8 shadow-xl border-2 border-orange-300">
              <div className="flex items-start gap-4">
                <span className="text-4xl">💡</span>
                <p className="text-xl text-gray-800 font-semibold leading-relaxed italic">
                  {conclusion}
                </p>
              </div>
            </div>
          </motion.div>
        )}
      </div>
    </div>
  );
}
