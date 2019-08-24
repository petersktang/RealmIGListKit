#  RealmIGListKit
Sample code to handle RealmChangeset updates within IGListKit in a Multi-Section CollectionView. The code is able to allow the same realm change source hitting multiple CollectionView sections at the same time without getting into integrity errors like.

<code>
Invalid update: invalid number of items in section x.
</code>

## Problem 1: 
Realm objects are mutable, and has to copied into an array before it can be used in IGListKit.

## Problem 2: 
When changes base on the same data source needs to be reflected onto multiple Collection View sections, this change has to happen at the same time and within the same batch update block.

## Solution:
Setup a handler store which registers all sections within the same Collection View that needs to have data reflected at the same time. Create a handler for each of these groups to manage both the snapshot(solution to problem 1) with a consolidated batch update block.

UICollectionView.performBatchUpdates() is used instead of ListBatchContext.performBatch()

# Reference
Adopt the randomizer logic from 
https://github.com/RxSwiftCommunity/RxRealmDataSources 


