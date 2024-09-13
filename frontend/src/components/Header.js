import React, { useState, useCallback, useRef, Suspense } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { useSpring, animated, config } from '@react-spring/web';
import { Canvas, useFrame } from '@react-three/fiber';
import { Text3D, Center } from '@react-three/drei';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import {
  ChakraProvider,
  extendTheme,
  Box,
  Flex,
  Button,
  Avatar,
  Menu,
  MenuButton,
  MenuList,
  MenuItem,
  IconButton,
  useDisclosure,
  Drawer,
  DrawerBody,
  DrawerHeader,
  DrawerOverlay,
  DrawerContent,
  DrawerCloseButton,
  VStack,
  Text,
  useColorModeValue,
} from '@chakra-ui/react';
import { FiMenu, FiChevronDown, FiLogOut } from 'react-icons/fi';
import { useInView } from 'react-intersection-observer';

gsap.registerPlugin(ScrollTrigger);

// Tema personalizado de Chakra UI
const theme = extendTheme({
  styles: {
    global: (props) => ({
      body: {
        bg: props.colorMode === 'dark' ? 'gray.900' : 'gray.50',
        color: props.colorMode === 'dark' ? 'white' : 'gray.800',
      },
    }),
  },
  config: {
    initialColorMode: 'dark',
    useSystemColorMode: false,
  },
});

// Componente de logo 3D animado
const AnimatedLogo = () => {
  const meshRef = useRef();
  useFrame((state) => {
    meshRef.current.rotation.y = Math.sin(state.clock.elapsedTime) * 0.2;
  });

  return (
    <mesh ref={meshRef}>
      <Text3D 
        font="/fonts/helvetiker_regular.typeface.json"
        size={0.5}
        height={0.2}
        curveSegments={12}
      >
        Sentinel
        <meshNormalMaterial />
      </Text3D>
    </mesh>
  );
};

// Componente de botón de navegación animado
const AnimatedNavButton = ({ children, isActive, ...props }) => {
  const [ref, inView] = useInView({
    threshold: 0.1,
    triggerOnce: true,
  });

  const springProps = useSpring({
    opacity: inView ? 1 : 0,
    transform: inView ? 'translateY(0px)' : 'translateY(20px)',
    config: config.wobbly,
  });

  return (
    <animated.div ref={ref} style={springProps}>
      <Button
        variant="ghost"
        color={isActive ? 'purple.400' : 'white'}
        _hover={{ bg: 'whiteAlpha.200' }}
        _active={{ bg: 'whiteAlpha.300' }}
        position="relative"
        overflow="hidden"
        {...props}
      >
        {children}
        {isActive && (
          <motion.div
            layoutId="activeIndicator"
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              height: '2px',
              background: 'currentColor',
            }}
            transition={{
              type: 'spring',
              stiffness: 500,
              damping: 30,
            }}
          />
        )}
      </Button>
    </animated.div>
  );
};

// Componente principal del encabezado
const UltraModernHeader = ({ user, signOut }) => {
  const location = useLocation();
  const { isOpen, onOpen, onClose } = useDisclosure();
  const btnRef = React.useRef();

  const [logoHovered, setLogoHovered] = useState(false);

  const navItems = [
    { label: 'Home', path: '/' },
    { label: 'Analysis', path: '/analysis' },
    { label: 'Reports', path: '/reports' },
    { label: 'About', path: '/about' },
  ];

  const handleSignOut = useCallback(() => {
    onClose();
    signOut();
  }, [onClose, signOut]);

  const headerBg = useColorModeValue('whiteAlpha.200', 'blackAlpha.400');
  const headerShadow = useColorModeValue('lg', 'dark-lg');

  // Animación del logo al hacer hover
  const logoSpring = useSpring({
    scale: logoHovered ? 1.1 : 1,
    config: config.wobbly,
  });

  return (
    <ChakraProvider theme={theme}>
      <Box
        as="header"
        position="fixed"
        top={0}
        left={0}
        right={0}
        zIndex={1000}
        bg={headerBg}
        boxShadow={headerShadow}
        backdropFilter="blur(10px)"
      >
        <Flex alignItems="center" justifyContent="space-between" maxW="1200px" mx="auto" px={4} py={2}>
          <Flex alignItems="center">
            <Box width="60px" height="60px" mr={4} cursor="pointer">
              <animated.div style={logoSpring}>
                <Canvas
                  onPointerEnter={() => setLogoHovered(true)}
                  onPointerLeave={() => setLogoHovered(false)}
                >
                  <ambientLight intensity={0.5} />
                  <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} />
                  <Suspense fallback={null}>
                    <Center>
                      <AnimatedLogo />
                    </Center>
                  </Suspense>
                </Canvas>
              </animated.div>
            </Box>
            <Flex display={{ base: 'none', md: 'flex' }}>
              {navItems.map((item) => (
                <AnimatedNavButton
                  key={item.label}
                  as={Link}
                  to={item.path}
                  isActive={location.pathname === item.path}
                  mr={2}
                >
                  {item.label}
                </AnimatedNavButton>
              ))}
            </Flex>
          </Flex>

          <Flex alignItems="center">
            <Menu>
              <MenuButton
                as={Button}
                rightIcon={<FiChevronDown />}
                variant="ghost"
                _hover={{ bg: 'whiteAlpha.200' }}
                _active={{ bg: 'whiteAlpha.300' }}
              >
                <Flex alignItems="center">
                  <Avatar size="sm" src={user.avatar} name={user.username} mr={2} />
                  <Text display={{ base: 'none', md: 'block' }}>{user.username}</Text>
                </Flex>
              </MenuButton>
              <MenuList bg={useColorModeValue('white', 'gray.800')}>
                <MenuItem icon={<FiLogOut />} onClick={handleSignOut}>
                  Sign Out
                </MenuItem>
              </MenuList>
            </Menu>

            <IconButton
              ref={btnRef}
              icon={<FiMenu />}
              variant="ghost"
              _hover={{ bg: 'whiteAlpha.200' }}
              _active={{ bg: 'whiteAlpha.300' }}
              aria-label="Open menu"
              display={{ base: 'flex', md: 'none' }}
              onClick={onOpen}
              ml={2}
            />
          </Flex>
        </Flex>
      </Box>

      <Drawer
        isOpen={isOpen}
        placement="right"
        onClose={onClose}
        finalFocusRef={btnRef}
      >
        <DrawerOverlay />
        <DrawerContent bg={useColorModeValue('white', 'gray.800')}>
          <DrawerCloseButton />
          <DrawerHeader>Menu</DrawerHeader>
          <DrawerBody>
            <VStack spacing={4} align="stretch">
              {navItems.map((item) => (
                <Button
                  key={item.label}
                  as={Link}
                  to={item.path}
                  variant="ghost"
                  justifyContent="flex-start"
                  onClick={onClose}
                >
                  {item.label}
                </Button>
              ))}
              <Button
                leftIcon={<FiLogOut />}
                variant="ghost"
                justifyContent="flex-start"
                onClick={handleSignOut}
              >
                Sign Out
              </Button>
            </VStack>
          </DrawerBody>
        </DrawerContent>
      </Drawer>
    </ChakraProvider>
  );
};

export default React.memo(UltraModernHeader);