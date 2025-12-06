'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface SplitSlideProps {
  slide: Slide;
}

export default function SplitSlide({ slide }: SplitSlideProps) {
  const { title, bulletPoints } = slide.content;

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.3,
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

  // Split bullet points into two columns
  const midPoint = bulletPoints ? Math.ceil(bulletPoints.length / 2) : 0;
  const leftPoints = bulletPoints?.slice(0, midPoint) || [];
  const rightPoints = bulletPoints?.slice(midPoint) || [];

  return (
    <div className="relative w-full h-full flex items-center justify-center p-16">
      {/* Background Gradient Blobs */}
      <div className="absolute inset-0">
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            x: [0, 50, 0],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: 'easeInOut',
          }}
          className="absolute top-20 left-20 w-80 h-80 bg-blue-400/20 rounded-full blur-3xl"
        />
        <motion.div
          animate={{
            scale: [1.2, 1, 1.2],
            x: [0, -50, 0],
          }}
          transition={{
            duration: 12,
            repeat: Infinity,
            ease: 'easeInOut',
          }}
          className="absolute bottom-20 right-20 w-80 h-80 bg-purple-400/20 rounded-full blur-3xl"
        />
      </div>

      <div className="relative z-10 w-full max-w-7xl">
        {/* Title */}
        <motion.div
          initial={{ y: -30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-5xl md:text-6xl font-bold mb-6 drop-shadow-lg
                       bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 
                       bg-clip-text text-transparent">
            {title}
          </h2>
          <motion.div
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ delay: 0.4, duration: 0.6 }}
            className="h-1 w-40 mx-auto bg-gradient-to-r from-blue-400 to-purple-400 rounded-full"
          />
        </motion.div>

        {/* Two Column Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          {/* Left Column */}
          <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="space-y-5"
          >
            {leftPoints.map((point, index) => {
              const isHeader = point.includes('📦') || point.includes('🔧') || 
                             point.includes('✅') || point.includes('🔒');
              const isEmpty = point.trim() === '';

              if (isEmpty) {
                return <div key={index} className="h-4" />;
              }

              return (
                <motion.div
                  key={index}
                  variants={itemVariants}
                  whileHover={{ scale: 1.02, x: 5 }}
                  className={`flex items-start gap-4 ${
                    isHeader 
                      ? 'bg-gradient-to-r from-blue-500 to-purple-600 text-white p-4 rounded-xl shadow-lg' 
                      : 'bg-white/80 p-4 rounded-xl backdrop-blur-sm border border-gray-200 shadow-md'
                  } hover:shadow-xl transition-all duration-300`}
                >
                  {!isHeader && point.startsWith('•') === false && !isEmpty && (
                    <div className="flex-shrink-0 mt-1">
                      <div className="w-3 h-3 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full shadow-md" />
                    </div>
                  )}
                  <p className={`flex-1 ${
                    isHeader ? 'text-xl font-bold text-white' : 'text-lg text-gray-800'
                  }`}>
                    {point}
                  </p>
                </motion.div>
              );
            })}
          </motion.div>

          {/* Right Column */}
          <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="space-y-5"
          >
            {rightPoints.map((point, index) => {
              const isHeader = point.includes('📦') || point.includes('🔧') || 
                             point.includes('✅') || point.includes('🔒');
              const isEmpty = point.trim() === '';

              if (isEmpty) {
                return <div key={index} className="h-4" />;
              }

              return (
                <motion.div
                  key={index}
                  variants={itemVariants}
                  whileHover={{ scale: 1.02, x: 5 }}
                  className={`flex items-start gap-4 ${
                    isHeader 
                      ? 'bg-gradient-to-r from-pink-500 to-rose-600 text-white p-4 rounded-xl shadow-lg' 
                      : 'bg-white/80 p-4 rounded-xl backdrop-blur-sm border border-gray-200 shadow-md'
                  } hover:shadow-xl transition-all duration-300`}
                >
                  {!isHeader && point.startsWith('•') === false && !isEmpty && (
                    <div className="flex-shrink-0 mt-1">
                      <div className="w-3 h-3 bg-gradient-to-r from-pink-500 to-rose-600 rounded-full shadow-md" />
                    </div>
                  )}
                  <p className={`flex-1 ${
                    isHeader ? 'text-xl font-bold text-white' : 'text-lg text-gray-800'
                  }`}>
                    {point}
                  </p>
                </motion.div>
              );
            })}
          </motion.div>
        </div>

        {/* Center Divider */}
        <motion.div
          initial={{ scaleY: 0 }}
          animate={{ scaleY: 1 }}
          transition={{ delay: 0.5, duration: 0.8 }}
          className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 
                   w-px h-2/3 bg-gradient-to-b from-transparent via-gray-400 to-transparent 
                   hidden lg:block"
        />
      </div>
    </div>
  );
}
