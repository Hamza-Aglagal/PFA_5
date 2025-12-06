'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface TableSlideProps {
  slide: Slide;
}

// Tool logos/icons mapping with colors
const toolsConfig: Record<string, { icon: string; color: string; gradient: string }> = {
  'ANSYS Mechanical': { 
    icon: '🏗️', 
    color: 'from-orange-400 to-red-500',
    gradient: 'from-orange-50 to-red-50',
  },
  'Abaqus/CAE': { 
    icon: '🔧', 
    color: 'from-blue-400 to-indigo-500',
    gradient: 'from-blue-50 to-indigo-50',
  },
  'SAP2000 CSI': { 
    icon: '📐', 
    color: 'from-green-400 to-emerald-500',
    gradient: 'from-green-50 to-emerald-50',
  },
  'DeepFEM (MIT)': { 
    icon: '🤖', 
    color: 'from-purple-400 to-pink-500',
    gradient: 'from-purple-50 to-pink-50',
  },
};

export default function TableSlide({ slide }: TableSlideProps) {
  const { title, subtitle, tableData } = slide.content;
  const [selectedRowIndex, setSelectedRowIndex] = useState<number | null>(null);
  const [isTransitioning, setIsTransitioning] = useState(false);

  const handleToggleView = () => {
    if (isTransitioning) return;
    
    setIsTransitioning(true);
    
    if (selectedRowIndex === null) {
      setSelectedRowIndex(0);
    } else if (selectedRowIndex < (tableData?.rows.length || 0) - 1) {
      setSelectedRowIndex(selectedRowIndex + 1);
    } else {
      setSelectedRowIndex(null);
    }
    
    setTimeout(() => setIsTransitioning(false), 600);
  };

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyPress = (e: KeyboardEvent) => {
      if ((e.key === 'v' || e.key === 'V') && !isTransitioning) {
        e.preventDefault();
        handleToggleView();
      }
    };

    window.addEventListener('keydown', handleKeyPress);
    return () => window.removeEventListener('keydown', handleKeyPress);
  }, [selectedRowIndex, tableData, isTransitioning]);

  const isSplitView = selectedRowIndex !== null;

  if (!tableData) return null;

  return (
    <div className="relative w-full h-full flex items-center justify-center p-16 overflow-hidden">
      {/* Title */}
      <motion.div
        initial={{ y: -30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.6 }}
        className="absolute top-12 left-1/2 transform -translate-x-1/2 z-20 text-center"
      >
        <h2 className="text-5xl font-bold drop-shadow-lg
                     bg-gradient-to-r from-emerald-600 via-teal-600 to-cyan-600 
                     bg-clip-text text-transparent">
          {title}
        </h2>
        {subtitle && (
          <p className="text-lg text-gray-700 font-medium mt-3">
            {subtitle}
          </p>
        )}
      </motion.div>

      {/* Toggle Button */}
      <motion.button
        initial={{ opacity: 0, scale: 0 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.5, type: 'spring', stiffness: 200 }}
        onClick={handleToggleView}
        disabled={isTransitioning}
        className="absolute top-12 right-12 z-30 w-16 h-16 bg-gradient-to-br from-teal-500 via-cyan-500 to-blue-500 
                 text-white rounded-full shadow-2xl hover:shadow-teal-500/50 hover:scale-110 transition-all
                 flex items-center justify-center text-3xl font-bold group disabled:opacity-50 disabled:cursor-not-allowed
                 border-4 border-white/30"
        whileHover={{ scale: isTransitioning ? 1 : 1.1, rotate: isTransitioning ? 0 : 5 }}
        whileTap={{ scale: isTransitioning ? 1 : 0.95 }}
      >
        <motion.span
          key={selectedRowIndex === null ? 'search' : selectedRowIndex}
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          exit={{ scale: 0, rotate: 180 }}
          transition={{ duration: 0.3 }}
        >
          {selectedRowIndex === null ? '🔍' : selectedRowIndex < tableData.rows.length - 1 ? '▶' : '↺'}
        </motion.span>
        
        {/* Keyboard hint tooltip */}
        <motion.div
          className="absolute -bottom-20 right-0 bg-gray-900 text-white px-4 py-2 rounded-xl 
                   text-sm whitespace-nowrap opacity-0 group-hover:opacity-100 transition-all duration-300
                   pointer-events-none shadow-xl border border-gray-700"
        >
          Appuyez sur <kbd className="px-2 py-1 bg-teal-500 rounded ml-1 font-mono font-bold">V</kbd>
          <div className="absolute top-0 right-4 transform -translate-y-1 w-0 h-0 border-l-4 border-l-transparent border-r-4 border-r-transparent border-b-4 border-b-gray-900 rotate-180" />
        </motion.div>
      </motion.button>

      {/* Main Content Area */}
      <div className="w-full h-full flex items-center justify-center mt-20">
        <div className="w-full max-w-7xl h-full flex gap-8 items-center justify-center">
          
          {/* Icon Cards View (when no selection) */}
          {!isSplitView && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              transition={{ duration: 0.5 }}
              className="w-full"
            >
              <div className="grid grid-cols-2 gap-8 max-w-5xl mx-auto">
                {tableData.rows.map((row, index) => {
                  const toolName = row[0];
                  const config = toolsConfig[toolName];
                  
                  return (
                    <motion.div
                      key={index}
                      initial={{ opacity: 0, y: 50, scale: 0.8 }}
                      animate={{ opacity: 1, y: 0, scale: 1 }}
                      transition={{ delay: 0.6 + index * 0.15, type: 'spring', stiffness: 150 }}
                      onClick={() => !isTransitioning && setSelectedRowIndex(index)}
                      whileHover={{ 
                        scale: 1.05, 
                        y: -10,
                        transition: { duration: 0.3 }
                      }}
                      className="relative cursor-pointer group"
                    >
                      {/* Card */}
                      <div className={`relative bg-gradient-to-br ${config.gradient} rounded-3xl p-10 
                                    border-4 border-white shadow-2xl overflow-hidden`}>
                        
                        {/* Animated glow effect */}
                        <motion.div
                          animate={{ 
                            scale: [1, 1.2, 1],
                            opacity: [0.3, 0.5, 0.3]
                          }}
                          transition={{ duration: 3, repeat: Infinity }}
                          className={`absolute inset-0 bg-gradient-to-br ${config.color} opacity-20 blur-2xl`}
                        />
                        
                        {/* Content */}
                        <div className="relative z-10 flex flex-col items-center text-center space-y-5">
                          {/* Large Icon with animation */}
                          <motion.div
                            className="relative"
                            animate={{
                              rotate: [0, 5, -5, 0],
                              scale: [1, 1.05, 1],
                            }}
                            transition={{
                              duration: 4,
                              repeat: Infinity,
                              ease: 'easeInOut',
                            }}
                          >
                            <div className={`w-32 h-32 bg-gradient-to-br ${config.color} rounded-3xl 
                                          flex items-center justify-center shadow-2xl border-4 border-white/50
                                          group-hover:shadow-3xl group-hover:border-white transition-all duration-300`}>
                              <span className="text-7xl">{config.icon}</span>
                            </div>
                            {/* Glow effect */}
                            <motion.div
                              animate={{ 
                                scale: [1, 1.3, 1], 
                                opacity: [0.4, 0.7, 0.4] 
                              }}
                              transition={{ duration: 2, repeat: Infinity }}
                              className={`absolute inset-0 bg-gradient-to-br ${config.color} rounded-3xl blur-xl -z-10`}
                            />
                          </motion.div>

                          {/* Tool Name */}
                          <motion.h3
                            className="text-3xl font-black text-gray-800 leading-tight"
                            whileHover={{ scale: 1.05 }}
                          >
                            {toolName}
                          </motion.h3>

                          {/* Decorative underline */}
                          <motion.div
                            initial={{ scaleX: 0 }}
                            animate={{ scaleX: 1 }}
                            transition={{ delay: 0.8 + index * 0.15, duration: 0.5 }}
                            className={`h-1.5 w-24 bg-gradient-to-r ${config.color} rounded-full shadow-lg`}
                          />

                          {/* Click hint */}
                          <motion.p
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ delay: 1 + index * 0.15 }}
                            className="text-sm font-bold text-gray-600 opacity-0 group-hover:opacity-100 transition-opacity"
                          >
                            Cliquez pour détails
                          </motion.p>
                        </div>

                        {/* Corner number badge */}
                        <motion.div
                          initial={{ scale: 0, rotate: -180 }}
                          animate={{ scale: 1, rotate: 0 }}
                          transition={{ delay: 1.2 + index * 0.15, type: 'spring' }}
                          className="absolute top-4 right-4 w-12 h-12 bg-white rounded-full shadow-lg 
                                   flex items-center justify-center border-2 border-gray-200"
                        >
                          <span className="text-xl font-black text-gray-700">{index + 1}</span>
                        </motion.div>
                      </div>
                    </motion.div>
                  );
                })}
              </div>
            </motion.div>
          )}

          {/* Details View (when item selected) */}
          <AnimatePresence>
            {isSplitView && selectedRowIndex !== null && (
              <motion.div
                key={selectedRowIndex}
                initial={{ opacity: 0, scale: 0.8, y: 50 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.8, y: 50 }}
                transition={{
                  duration: 0.6,
                  ease: [0.34, 1.56, 0.64, 1],
                }}
                className="w-full max-w-6xl h-[calc(100vh-250px)]"
              >
                {/* Professional Details Card */}
                <div className="w-full h-full bg-white rounded-3xl shadow-2xl border-4 border-cyan-200 overflow-hidden flex flex-col">
                  {/* Top colored bar */}
                  <div className={`h-3 bg-gradient-to-r ${toolsConfig[tableData.rows[selectedRowIndex][0]].color}`}></div>

                  <div className="flex-1 p-8 flex flex-col overflow-hidden">
                    {/* Header with icon and title */}
                    <div className="flex items-center gap-6 mb-6 pb-6 border-b-4 border-cyan-100">
                      {/* Icon */}
                      <motion.div
                        initial={{ scale: 0, rotate: -180 }}
                        animate={{ scale: 1, rotate: 0 }}
                        transition={{ type: 'spring', stiffness: 200 }}
                        className="relative flex-shrink-0"
                      >
                        <div className={`w-28 h-28 bg-gradient-to-br ${toolsConfig[tableData.rows[selectedRowIndex][0]].color} 
                                      rounded-3xl flex items-center justify-center shadow-2xl border-4 border-white`}>
                          <span className="text-6xl">{toolsConfig[tableData.rows[selectedRowIndex][0]].icon}</span>
                        </div>
                        <motion.div
                          animate={{ scale: [1, 1.2, 1], opacity: [0.4, 0.6, 0.4] }}
                          transition={{ duration: 2, repeat: Infinity }}
                          className={`absolute inset-0 bg-gradient-to-br ${toolsConfig[tableData.rows[selectedRowIndex][0]].color} 
                                    rounded-3xl blur-xl -z-10`}
                        />
                      </motion.div>

                      {/* Title */}
                      <div className="flex-1">
                        <h3 className="text-5xl font-black bg-gradient-to-r from-slate-800 via-teal-700 to-cyan-700 
                                     bg-clip-text text-transparent">
                          {tableData.rows[selectedRowIndex][0]}
                        </h3>
                        <motion.div
                          initial={{ scaleX: 0 }}
                          animate={{ scaleX: 1 }}
                          transition={{ delay: 0.3, duration: 0.6 }}
                          className={`h-2 bg-gradient-to-r ${toolsConfig[tableData.rows[selectedRowIndex][0]].color} 
                                    rounded-full origin-left mt-4 shadow-lg w-2/3`}
                        />
                      </div>

                      {/* Counter Badge */}
                      <motion.div
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        transition={{ delay: 0.2, type: 'spring' }}
                        className="flex-shrink-0"
                      >
                        <div className={`w-24 h-24 bg-gradient-to-br ${toolsConfig[tableData.rows[selectedRowIndex][0]].color} 
                                      rounded-full shadow-2xl border-4 border-white flex items-center justify-center`}>
                          <div className="text-center">
                            <div className="text-3xl font-black text-white">{selectedRowIndex + 1}</div>
                            <div className="text-xs text-white/90 font-bold">/ {tableData.rows.length}</div>
                          </div>
                        </div>
                      </motion.div>
                    </div>

                    {/* Content Grid - Professional Layout without subtitles */}
                    <div className="flex-1 grid grid-cols-2 gap-4">
                      
                      {/* Left Column */}
                      <div className="space-y-4">
                        
                        {/* Image */}
                        {tableData.rowImages && tableData.rowImages[selectedRowIndex] && (
                          <motion.div
                            initial={{ x: -30, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.2 }}
                            className="bg-gradient-to-br from-slate-50 to-slate-100 rounded-2xl p-4 border-2 border-slate-200 shadow-lg"
                          >
                            <div className="bg-white rounded-xl p-3 shadow-inner">
                              <img 
                                src={tableData.rowImages[selectedRowIndex]} 
                                alt={tableData.rows[selectedRowIndex][0]}
                                className="w-full h-28 object-contain"
                              />
                            </div>
                          </motion.div>
                        )}

                        {/* Description */}
                        {tableData.rowDetails && tableData.rowDetails[selectedRowIndex] && (
                          <motion.div
                            initial={{ x: -30, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.3 }}
                            className="bg-gradient-to-br from-blue-50 to-cyan-50 rounded-2xl p-4 border-2 border-blue-200 shadow-lg"
                          >
                            <p className="text-sm text-slate-800 leading-relaxed font-medium">
                              {tableData.rowDetails[selectedRowIndex].description}
                            </p>
                          </motion.div>
                        )}

                        {/* Avantages */}
                        {tableData.rowDetails && tableData.rowDetails[selectedRowIndex]?.avantages && (
                          <motion.div
                            initial={{ x: -30, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.4 }}
                            className="bg-gradient-to-br from-green-50 to-emerald-50 rounded-2xl p-4 border-2 border-green-200 shadow-lg"
                          >
                            <ul className="space-y-2">
                              {tableData.rowDetails[selectedRowIndex].avantages!.map((item, i) => (
                                <motion.li 
                                  key={i}
                                  initial={{ x: -20, opacity: 0 }}
                                  animate={{ x: 0, opacity: 1 }}
                                  transition={{ delay: 0.5 + i * 0.1 }}
                                  className="text-sm text-slate-800 flex items-start gap-2 font-medium"
                                >
                                  <span className="text-green-500 text-lg flex-shrink-0">✓</span>
                                  <span>{item}</span>
                                </motion.li>
                              ))}
                            </ul>
                          </motion.div>
                        )}
                      </div>

                      {/* Right Column */}
                      <div className="space-y-4">
                        
                        {/* Limites */}
                        {tableData.rowDetails && tableData.rowDetails[selectedRowIndex] && (
                          <motion.div
                            initial={{ x: 30, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.3 }}
                            className="bg-gradient-to-br from-orange-50 to-red-50 rounded-2xl p-4 border-2 border-orange-200 shadow-lg"
                          >
                            <ul className="space-y-2">
                              {tableData.rowDetails[selectedRowIndex].limites.map((item, i) => (
                                <motion.li 
                                  key={i}
                                  initial={{ x: 20, opacity: 0 }}
                                  animate={{ x: 0, opacity: 1 }}
                                  transition={{ delay: 0.4 + i * 0.1 }}
                                  className="text-sm text-slate-800 flex items-start gap-2 font-medium"
                                >
                                  <span className="text-orange-500 text-lg flex-shrink-0">⚠</span>
                                  <span>{item}</span>
                                </motion.li>
                              ))}
                            </ul>
                          </motion.div>
                        )}

                        {/* Technologies */}
                        {tableData.rowDetails && tableData.rowDetails[selectedRowIndex]?.technologies && (
                          <motion.div
                            initial={{ x: 30, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.5 }}
                            className="bg-gradient-to-br from-purple-50 to-indigo-50 rounded-2xl p-4 border-2 border-purple-200 shadow-lg"
                          >
                            <div className="flex flex-wrap gap-2">
                              {tableData.rowDetails[selectedRowIndex].technologies!.map((tech, i) => (
                                <motion.span 
                                  key={i}
                                  initial={{ scale: 0 }}
                                  animate={{ scale: 1 }}
                                  transition={{ delay: 0.6 + i * 0.05, type: 'spring' }}
                                  className="px-3 py-1.5 bg-purple-200 text-purple-900 rounded-full text-sm font-bold shadow-md"
                                >
                                  {tech}
                                </motion.span>
                              ))}
                            </div>
                          </motion.div>
                        )}

                        {/* Coût */}
                        {tableData.rowDetails && tableData.rowDetails[selectedRowIndex]?.cout && (
                          <motion.div
                            initial={{ x: 30, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.6 }}
                            className="bg-gradient-to-br from-yellow-50 to-amber-50 rounded-2xl p-4 border-2 border-yellow-300 shadow-lg"
                          >
                            <p className="text-base font-black text-amber-800 text-center">
                              💰 {tableData.rowDetails[selectedRowIndex].cout}
                            </p>
                          </motion.div>
                        )}

                        {/* Référence */}
                        {tableData.rowDetails && tableData.rowDetails[selectedRowIndex] && (
                          <motion.div
                            initial={{ x: 30, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            transition={{ delay: 0.7 }}
                            className="bg-gradient-to-br from-teal-50 to-cyan-50 rounded-2xl p-4 border-2 border-teal-200 shadow-lg"
                          >
                            <p className="text-sm text-teal-800 font-bold text-center">
                              🔗 {tableData.rowDetails[selectedRowIndex].reference}
                            </p>
                          </motion.div>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
