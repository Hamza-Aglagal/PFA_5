'use client';

import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface PlanSlideProps {
  slide: Slide;
}

export default function PlanSlide({ slide }: PlanSlideProps) {
  const { title, items } = slide.content;

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
        delayChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { x: -50, opacity: 0 },
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
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0" style={{
          backgroundImage: `radial-gradient(circle at 2px 2px, rgba(59, 130, 246, 0.5) 1px, transparent 0)`,
          backgroundSize: '40px 40px',
        }} />
      </div>

      <div className="relative z-10 w-full max-w-5xl">
        {/* Title */}
        <motion.div
          initial={{ y: -50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.8, type: 'spring' }}
          className="text-center mb-16"
        >
          <h2 className="text-6xl font-bold mb-4 drop-shadow-lg
                       bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 
                       bg-clip-text text-transparent">
            {title}
          </h2>
          <motion.div
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ delay: 0.5, duration: 0.8 }}
            className="h-2 w-48 mx-auto bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 rounded-full"
          />
        </motion.div>

        {/* Items Grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
          className="grid grid-cols-1 md:grid-cols-2 gap-6"
        >
          {items?.map((item, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              whileHover={{ scale: 1.05, x: 10 }}
              className="group relative"
            >
              <div className="flex items-center gap-4 bg-white/90 backdrop-blur-md 
                            p-6 rounded-2xl border-2 border-gray-200 hover:border-blue-400
                            transition-all duration-300 shadow-xl hover:shadow-2xl">
                {/* Number Badge */}
                <div className="flex-shrink-0">
                  <div className="w-14 h-14 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 
                                flex items-center justify-center shadow-lg group-hover:scale-110 
                                transition-transform duration-300">
                    <span className="text-white font-bold text-xl">
                      {String(index + 1).padStart(2, '0')}
                    </span>
                  </div>
                </div>

                {/* Text */}
                <div className="flex-1">
                  <p className="text-gray-800 text-xl font-medium">{item}</p>
                </div>

                {/* Arrow Icon */}
                <div className="flex-shrink-0 opacity-0 group-hover:opacity-100 
                              transition-opacity duration-300">
                  <svg
                    className="w-6 h-6 text-blue-600"
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
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Decorative Elements */}
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ delay: 1, duration: 1 }}
          className="absolute -top-10 -right-10 w-40 h-40 bg-gradient-to-br from-pink-400/30 to-purple-400/30 
                   rounded-full blur-3xl"
        />
        <motion.div
          initial={{ scale: 0, rotate: 180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ delay: 1.2, duration: 1 }}
          className="absolute -bottom-10 -left-10 w-40 h-40 bg-gradient-to-br from-blue-400/30 to-cyan-400/30 
                   rounded-full blur-3xl"
        />
      </div>
    </div>
  );
}
