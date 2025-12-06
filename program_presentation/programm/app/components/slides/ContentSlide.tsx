'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface ContentSlideProps {
  slide: Slide;
}

export default function ContentSlide({ slide }: ContentSlideProps) {
  const { title, subtitle, content, bulletPoints } = slide.content;

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2,
      },
    },
  };

  const itemVariants = {
    hidden: { x: -30, opacity: 0 },
    visible: {
      x: 0,
      opacity: 1,
      transition: {
        type: 'spring',
        stiffness: 100,
      },
    },
  };

  return (
    <div className="relative w-full h-full flex items-center justify-center p-16">
      {/* Background Glow */}
      <div className="absolute inset-0">
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: 'easeInOut',
          }}
          className="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-400/40 rounded-full blur-3xl"
        />
      </div>

      <div className="relative z-10 w-full max-w-6xl">
        {/* Title */}
        <motion.div
          initial={{ y: -30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.6 }}
          className="mb-12"
        >
          <h2 className="text-5xl md:text-6xl font-bold mb-6 drop-shadow-lg
                       bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 
                       bg-clip-text text-transparent">
            {title}
          </h2>
          {subtitle && (
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.3 }}
              className="text-2xl text-gray-700 font-medium"
            >
              {subtitle}
            </motion.p>
          )}
          <motion.div
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ delay: 0.4, duration: 0.6 }}
            className="h-1 w-32 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full mt-6"
          />
        </motion.div>

        {/* Content (if text) */}
        {content && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="mb-8"
          >
            <pre className="text-gray-800 text-xl font-mono whitespace-pre-wrap 
                         bg-white/80 backdrop-blur-sm p-8 rounded-2xl border-2 border-gray-200 shadow-lg">
              {content}
            </pre>
          </motion.div>
        )}

        {/* Bullet Points */}
        {bulletPoints && bulletPoints.length > 0 && (
          <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="space-y-5"
          >
            {bulletPoints.map((point, index) => {
              // Check if it's an empty line or section header
              const isHeader = point.startsWith('📅') || point.startsWith('✅') || point.startsWith('🔒');
              const isEmpty = point.trim() === '';

              if (isEmpty) {
                return <div key={index} className="h-4" />;
              }

              return (
                <motion.div
                  key={index}
                  variants={itemVariants}
                  className={`flex items-start gap-4 ${isHeader ? 'mt-6' : ''}`}
                >
                  {!isHeader && (
                    <div className="flex-shrink-0 mt-2">
                      <motion.div
                        whileHover={{ scale: 1.3, rotate: 180 }}
                        className="w-4 h-4 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full shadow-md"
                      />
                    </div>
                  )}
                  <div className={`flex-1 ${
                    isHeader 
                      ? 'bg-gradient-to-r from-blue-500 to-purple-600 text-white p-4 rounded-xl shadow-lg' 
                      : 'bg-white/70 p-4 rounded-xl backdrop-blur-sm border border-gray-200'
                  }`}>
                    <p className={`${
                      isHeader ? 'text-2xl font-bold' : 'text-gray-800 text-xl'
                    }`}>
                      {point}
                    </p>
                  </div>
                </motion.div>
              );
            })}
          </motion.div>
        )}

        {/* Decorative Icon */}
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ delay: 1, duration: 1 }}
          className="absolute top-10 right-10 opacity-10"
        >
          <svg className="w-32 h-32 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10.394 2.08a1 1 0 00-.788 0l-7 3a1 1 0 000 1.84L5.25 8.051a.999.999 0 01.356-.257l4-1.714a1 1 0 11.788 1.838L7.667 9.088l1.94.831a1 1 0 00.787 0l7-3a1 1 0 000-1.838l-7-3zM3.31 9.397L5 10.12v4.102a8.969 8.969 0 00-1.05-.174 1 1 0 01-.89-.89 11.115 11.115 0 01.25-3.762zM9.3 16.573A9.026 9.026 0 007 14.935v-3.957l1.818.78a3 3 0 002.364 0l5.508-2.361a11.026 11.026 0 01.25 3.762 1 1 0 01-.89.89 8.968 8.968 0 00-5.35 2.524 1 1 0 01-1.4 0zM6 18a1 1 0 001-1v-2.065a8.935 8.935 0 00-2-.712V17a1 1 0 001 1z" />
          </svg>
        </motion.div>
      </div>
    </div>
  );
}
