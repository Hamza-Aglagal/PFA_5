'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface TimelineSlideProps {
  slide: Slide;
}

export default function TimelineSlide({ slide }: TimelineSlideProps) {
  const { title, intro, timeline, conclusion } = slide.content;

  return (
    <div className={`relative w-full h-full flex items-center justify-center p-16 ${slide.background || 'bg-white'}`}>
      <div className="max-w-6xl w-full">
        {/* Title */}
        <motion.div
          initial={{ opacity: 0, y: -30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-8"
        >
          <h1 className="text-6xl font-bold bg-gradient-to-r from-blue-600 via-indigo-600 to-violet-600 bg-clip-text text-transparent">
            {title}
          </h1>
        </motion.div>

        {/* Intro */}
        {intro && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="text-center mb-12"
          >
            <p className="text-xl text-gray-700 max-w-4xl mx-auto">
              {intro}
            </p>
          </motion.div>
        )}

        {/* Timeline */}
        <div className="relative mt-16">
          {/* Horizontal Line */}
          <motion.div
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ duration: 1, delay: 0.4 }}
            className="absolute top-12 left-0 right-0 h-2 bg-gradient-to-r from-blue-500 via-indigo-500 to-violet-500 rounded-full origin-left"
          ></motion.div>

          {/* Timeline Steps */}
          <div className="relative flex justify-between items-start pt-4">
            {timeline?.map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 50 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: 0.6 + index * 0.15 }}
                className="flex flex-col items-center relative"
                style={{ flex: 1 }}
              >
                {/* Step Circle */}
                <div className="relative z-10 w-16 h-16 bg-gradient-to-br from-blue-500 to-violet-600 rounded-full flex items-center justify-center shadow-2xl mb-6">
                  <span className="text-white text-2xl font-bold">{index + 1}</span>
                </div>

                {/* Step Label */}
                <div className="bg-white rounded-xl p-4 shadow-lg border-2 border-indigo-200 min-w-[140px] text-center">
                  <p className="text-base font-semibold text-gray-800">{step}</p>
                </div>

                {/* Arrow (except for last item) */}
                {index < (timeline?.length || 0) - 1 && (
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.8 + index * 0.15 }}
                    className="absolute top-8 left-[60%] text-4xl text-indigo-400"
                  >
                    →
                  </motion.div>
                )}
              </motion.div>
            ))}
          </div>
        </div>

        {/* Conclusion */}
        {conclusion && (
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 1.2 }}
            className="mt-16 text-center"
          >
            <div className="inline-block bg-gradient-to-r from-blue-100 to-violet-100 rounded-full px-8 py-4 shadow-lg">
              <p className="text-lg text-gray-800 font-medium">
                🔄 {conclusion}
              </p>
            </div>
          </motion.div>
        )}
      </div>
    </div>
  );
}
