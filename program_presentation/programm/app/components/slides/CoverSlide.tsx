'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface CoverSlideProps {
  slide: Slide;
}

export default function CoverSlide({ slide }: CoverSlideProps) {
  const { title, subtitle, contact, date } = slide.content;

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
        delayChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { y: 50, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: {
        type: 'spring',
        stiffness: 100,
        damping: 12,
      },
    },
  };

  return (
    <div className="relative w-full h-full flex items-center justify-center overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0">
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            rotate: [0, 90, 0],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: 'linear',
          }}
          className="absolute top-20 left-20 w-64 h-64 bg-blue-400/30 rounded-full blur-3xl"
        />
        <motion.div
          animate={{
            scale: [1.2, 1, 1.2],
            rotate: [90, 0, 90],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: 'linear',
          }}
          className="absolute bottom-20 right-20 w-80 h-80 bg-purple-400/30 rounded-full blur-3xl"
        />
        <motion.div
          animate={{
            scale: [1, 1.3, 1],
            rotate: [0, -90, 0],
          }}
          transition={{
            duration: 18,
            repeat: Infinity,
            ease: 'linear',
          }}
          className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 
                   w-96 h-96 bg-pink-400/30 rounded-full blur-3xl"
        />
      </div>

      {/* Content */}
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="relative z-10 text-center max-w-6xl px-12"
      >
        {/* Subtitle Badge */}
        {subtitle && (
          <motion.div variants={itemVariants} className="mb-8">
            <div className="inline-block bg-gradient-to-r from-blue-500 to-purple-600 px-8 py-3 
                          rounded-full shadow-2xl">
              <p className="text-white text-xl font-semibold">{subtitle}</p>
            </div>
          </motion.div>
        )}

        {/* Main Title */}
        <motion.h1
          variants={itemVariants}
          className="text-5xl md:text-6xl lg:text-7xl font-bold mb-12 
                   leading-tight drop-shadow-2xl
                   bg-gradient-to-r from-blue-700 via-purple-700 to-pink-700 
                   bg-clip-text text-transparent"
        >
          {title}
        </motion.h1>

        {/* Contact Info */}
        {contact && (
          <motion.div variants={itemVariants} className="mb-8">
            <div className="inline-flex items-center gap-4 bg-white/80 backdrop-blur-md 
                          px-8 py-4 rounded-2xl border border-gray-200 shadow-xl">
              <svg className="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                <path d="M2 5a2 2 0 012-2h7a2 2 0 012 2v4a2 2 0 01-2 2H9l-3 3v-3H4a2 2 0 01-2-2V5z" />
                <path d="M15 7v2a4 4 0 01-4 4H9.828l-1.766 1.767c.28.149.599.233.938.233h2l3 3v-3h2a2 2 0 002-2V9a2 2 0 00-2-2h-1z" />
              </svg>
              <p className="text-gray-800 text-lg font-medium">{contact}</p>
            </div>
          </motion.div>
        )}

        {/* Date */}
        {date && (
          <motion.div variants={itemVariants}>
            <p className="text-gray-700 text-xl font-light">{date}</p>
          </motion.div>
        )}

        {/* Decorative Icons */}
        <motion.div
          variants={itemVariants}
          className="mt-16 flex justify-center gap-8"
        >
          {[
            { icon: '📱', label: 'Mobile' },
            { icon: '🌐', label: 'Web' },
            { icon: '⚙️', label: 'Backend' },
            { icon: '🤖', label: 'IA' },
          ].map((item, index) => (
            <motion.div
              key={index}
              whileHover={{ scale: 1.2, rotate: 360 }}
              transition={{ type: 'spring', stiffness: 300 }}
              className="flex flex-col items-center gap-2"
            >
              <div className="text-5xl">{item.icon}</div>
              <p className="text-gray-700 text-sm font-medium">{item.label}</p>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>

      {/* Bottom Wave */}
      <div className="absolute bottom-0 left-0 right-0">
        <svg
          viewBox="0 0 1440 120"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full"
        >
          <motion.path
            initial={{ pathLength: 0, opacity: 0 }}
            animate={{ pathLength: 1, opacity: 0.3 }}
            transition={{ duration: 2, ease: 'easeInOut' }}
            d="M0,64L48,58.7C96,53,192,43,288,48C384,53,480,75,576,80C672,85,768,75,864,64C960,53,1056,43,1152,42.7C1248,43,1344,53,1392,58.7L1440,64L1440,120L1392,120C1344,120,1248,120,1152,120C1056,120,960,120,864,120C768,120,672,120,576,120C480,120,384,120,288,120C192,120,96,120,48,120L0,120Z"
            fill="black"
            fillOpacity="0.05"
          />
        </svg>
      </div>
    </div>
  );
}
