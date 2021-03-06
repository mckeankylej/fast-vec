{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

{-# OPTIONS_GHC -Wall -Werror -Wno-unticked-promoted-constructors #-}
module Data.Vector.Generic.Mutable.Sized where

import Prelude (Bool)

import Data.Vector.Generic.Internal.Sized (MVec(..))

import Data.Vector.Generic.Mutable (MVector)
import qualified Data.Vector.Generic.Mutable as M
import Control.Monad.Primitive (PrimMonad(..))

import Data.Coerce (coerce)
import Unsafe.Coerce (unsafeCoerce)

import Data.Type.Equality ((:~:)(..))
import Data.Singletons.Prelude (SingI(..),PNum(..),POrd(..))
import Data.Singletons.Decide (SDecide(..),Decision)
import Data.Nat.Internal (Sing(..),Bound(..))
import Data.Nat (type Nat(..),type SNat,zero)

tightenMonad :: m (v s a) -> m (MVec v s a n)
tightenMonad = unsafeCoerce

length :: (MVector v a) => MVec v s a n -> SNat n
{-# INLINE length #-}
length (MVec vs) = SNat (M.length vs)

null :: (MVector v a) => MVec v s a n -> Decision (n :~: Z)
{-# INLINE null #-}
null vs = length vs %~ zero

init :: (MVector v a) => MVec v s a (S n) -> MVec v s a n
{-# INLINE init #-}
init (MVec vs) = MVec (M.unsafeInit vs)

tail :: (MVector v a) => MVec v s a (S n) -> MVec v s a n
{-# INLINE tail #-}
tail (MVec vs) = MVec (M.unsafeTail vs)

take :: (MVector v a) => SNat i -> MVec v s a j -> MVec v s a (Min i j)
{-# INLINE take #-}
take (SNat amount) (MVec vs) = MVec (M.unsafeTake amount vs)

drop :: (MVector v a) => SNat i -> MVec v s a (i :+ n) -> MVec v s a n
{-# INLINE drop #-}
drop (SNat amount) (MVec vs) = MVec (M.unsafeDrop amount vs)

splitAt :: (MVector v a) => SNat i -> MVec v s a (i :+ n) -> (MVec v s a i, MVec v s a n)
{-# INLINE splitAt #-}
splitAt (SNat amount) (MVec vs) = coerce (M.splitAt amount vs)

overlaps :: (MVector v a) => MVec v s a n -> MVec v s a m -> Bool
{-# INLINE overlaps #-}
overlaps (MVec vs) (MVec ws) = M.overlaps vs ws

new :: (MVector v a, PrimMonad m) => SNat n -> m (MVec v (PrimState m) a n)
{-# INLINE new #-}
new (SNat amount) = tightenMonad (M.unsafeNew amount)

replicate :: (MVector v a, PrimMonad m) => SNat n -> a -> m (MVec v (PrimState m) a n)
{-# INLINE replicate #-}
replicate (SNat amount) x = tightenMonad (M.replicate amount x)

replicate' :: (MVector v a, PrimMonad m, SingI n) => a -> m (MVec v (PrimState m) a n)
{-# INLINE replicate' #-}
replicate' x = replicate sing x

replicateM :: (MVector v a, PrimMonad m) => SNat n -> m a -> m (MVec v (PrimState m) a n)
{-# INLINE replicateM #-}
replicateM (SNat amount) x = tightenMonad (M.replicateM amount x)

replicateM' :: (MVector v a, PrimMonad m, SingI n) => m a -> m (MVec v (PrimState m) a n)
{-# INLINE replicateM' #-}
replicateM' x = replicateM sing x

clone :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> m (MVec v (PrimState m) a n)
{-# INLINE clone #-}
clone (MVec vs) = tightenMonad (M.clone vs)

grow :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> SNat l -> m (MVec v (PrimState m) a (n :+ l))
{-# INLINE grow #-}
grow (MVec vs) (SNat amount) = tightenMonad (M.unsafeGrow vs amount)

growFront :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> SNat l -> m (MVec v (PrimState m) a (n :+ l))
{-# INLINE growFront #-}
growFront (MVec vs) (SNat amount) = tightenMonad (M.unsafeGrowFront vs amount)

clear :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> m ()
{-# INLINE clear #-}
clear (MVec vs) = M.clear vs

read :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> Bound n -> m a
{-# INLINE read #-}
read (MVec vs) (Bound i) = M.unsafeRead vs i

write :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> Bound n -> a -> m ()
{-# INLINE write #-}
write (MVec vs) (Bound i) x = M.unsafeWrite vs i x

modify :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> (a -> a) -> Bound n -> m ()
{-# INLINE modify #-}
modify (MVec vs) f (Bound i) = M.unsafeModify vs f i

swap :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> Bound n -> Bound n -> m ()
{-# INLINE swap #-}
swap (MVec vs) (Bound x) (Bound y) = M.unsafeSwap vs x y

exchange :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> Bound n -> a -> m a
{-# INLINE exchange #-}
exchange (MVec vs) (Bound i) x = M.unsafeExchange vs i x

set :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> a -> m ()
{-# INLINE set #-}
set (MVec vs) x = M.set vs x

copy :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> MVec v (PrimState m) a n -> m ()
{-# INLINE copy #-}
copy (MVec vs) (MVec ws) = M.copy vs ws

unsafeCopy :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> MVec v (PrimState m) a n -> m ()
{-# INLINE unsafeCopy #-}
unsafeCopy (MVec vs) (MVec ws) = M.unsafeCopy vs ws

move :: (MVector v a, PrimMonad m) => MVec v (PrimState m) a n -> MVec v (PrimState m) a n -> m ()
{-# INLINE move #-}
move (MVec vs) (MVec ws) = M.unsafeMove vs ws
