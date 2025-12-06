'use client';

/**
 * Home Page
 * Simple landing page - presentations are created in code
 */

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { getAllPresentations } from '@/lib/presentations';
import { Presentation } from '@/lib/types';

export default function Home() {
  const router = useRouter();
  const [presentations, setPresentations] = useState<Presentation[]>([]);

  useEffect(() => {
    setPresentations(getAllPresentations());
  }, []);



  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: {
        duration: 0.5,
      },
    },
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-violet-900">
      {/* Animated Background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-purple-500 rounded-full 
                      mix-blend-multiply filter blur-3xl opacity-20 animate-blob" />
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-pink-500 rounded-full 
                      mix-blend-multiply filter blur-3xl opacity-20 animate-blob animation-delay-2000" />
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 
                      w-80 h-80 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl 
                      opacity-20 animate-blob animation-delay-4000" />
      </div>

      {/* Content */}
      <div className="relative z-10 container mx-auto px-6 py-12">
        {/* Header */}
        <motion.div
          initial={{ y: -50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h1 className="text-6xl md:text-7xl lg:text-8xl font-bold text-white mb-6 
                       bg-clip-text text-transparent bg-gradient-to-r from-blue-400 
                       via-purple-400 to-pink-400">
            Modern Presentations
          </h1>
          <p className="text-xl md:text-2xl text-white/80 font-light max-w-2xl mx-auto">
            Stunning animated presentations with creative designs
          </p>
        </motion.div>

        {/* Presentation Card */}
        {presentations.length > 0 && (
          <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="max-w-2xl mx-auto"
          >
            {presentations.map((presentation) => (
              <motion.div
                key={presentation.id}
                variants={itemVariants}
                onClick={() => router.push(`/presentation/${presentation.id}`)}
                className="group relative bg-white/10 backdrop-blur-lg rounded-3xl 
                         overflow-hidden border border-white/20 shadow-2xl 
                         hover:shadow-3xl transition-all duration-500 
                         hover:scale-105 hover:border-white/40 cursor-pointer"
              >
                {/* Preview Gradient */}
                <div className="h-64 bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 relative overflow-hidden">
                  <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 
                                transition-all duration-300" />
                  
                  {/* Animated Background Elements */}
                  <div className="absolute top-10 left-10 w-32 h-32 bg-white/10 rounded-full blur-2xl animate-pulse" />
                  <div className="absolute bottom-10 right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl animate-pulse animation-delay-2000" />
                  
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="text-center space-y-4">
                      <motion.h3 
                        className="text-5xl font-bold text-white px-4"
                        initial={{ scale: 0.9, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        transition={{ delay: 0.2 }}
                      >
                        {presentation.title}
                      </motion.h3>
                      <motion.p 
                        className="text-lg text-white/90"
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ delay: 0.4 }}
                      >
                        {presentation.slides.length} slides
                      </motion.p>
                    </div>
                  </div>
                </div>

                {/* Info */}
                <div className="p-8 space-y-6">
                  {presentation.description && (
                    <p className="text-white/80 text-center text-lg">
                      {presentation.description}
                    </p>
                  )}

                  <div className="flex justify-center">
                    <button
                      className="px-12 py-4 bg-gradient-to-r from-blue-600 to-purple-600 
                               text-white text-lg font-bold rounded-xl hover:from-blue-700 
                               hover:to-purple-700 transition-all duration-300 shadow-xl
                               hover:shadow-2xl transform hover:scale-105 flex items-center gap-3"
                    >
                      <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z"/>
                      </svg>
                      Start Presentation
                    </button>
                  </div>

                  {/* Stats */}
                  <div className="grid grid-cols-3 gap-4 pt-6 border-t border-white/20">
                    <div className="text-center">
                      <p className="text-2xl font-bold text-white">
                        {presentation.slides.length}
                      </p>
                      <p className="text-white/60 text-sm">Slides</p>
                    </div>
                    <div className="text-center">
                      <p className="text-2xl font-bold text-white">
                        {presentation.design || 'design1'}
                      </p>
                      <p className="text-white/60 text-sm">Design</p>
                    </div>
                    <div className="text-center">
                      <p className="text-2xl font-bold text-white">✨</p>
                      <p className="text-white/60 text-sm">Animated</p>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </motion.div>
        )}
      </div>

      {/* Footer */}
      <motion.footer
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1 }}
        className="relative z-10 text-center py-8 text-white/50"
      >
        <p>Built with Next.js, TypeScript, Tailwind CSS, and Framer Motion</p>
      </motion.footer>
    </div>
  );
}
