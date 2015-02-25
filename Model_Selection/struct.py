from collections import deque
from copy import deepcopy
import numpy as np
import heapq


class Section(list):


    def __init__(self, adv, bound, label, prev, next):
        
        self.append(adv)
        self.act = True
        self.adv = adv
        self.bound = bound
        self.label = label
        self.prev = prev
        self.next = next

    
    def __repr__(self):

        return repr({"adv": self.adv, "bound": self.bound, "label": self.label})


class Partition(object):


    def __init__(self, labels):

        self.heap = []
        self.classifiers = []
        self.start = self.end = None

        self._append(Section(1, 0, y[0], None, None))

        for i in range(1, len(y)):
            if y[i] == self.heap[-1].label:
                self.heap[-1].bound += 1
                self.heap[-1].adv += 1
                self.heap[-1][0] += 1
            else:
                self._append(Section(1, i, y[i], None, None))

        self._heapify()


    def __repr__(self):

        return str(self.flatten())

        
    def select(self, nint, verb = False, save = False):
        
        ninit = len(self.flatten())
        if ninit % 2 != nint % 2: self._remove_one()
        if save: self.classifiers.append(deepcopy(self.flatten()))
        if verb: print(self.flatten())
        
        for i in range((ninit - nint) // 2):
            self._remove_two()
            if verb: print(self.flatten())
            if save: self.classifiers.append(deepcopy(self.flatten()))
        
        return(save and self.classifiers or deepcopy(self.flatten()))


    def flatten(self):
        
        sections = []
        cursor = self.start
        while cursor != None:
            sections.append({"adv": cursor.adv, "bound": cursor.bound, "label": cursor.label})
            cursor = cursor.next
        
        return(sections)


    def _append(self, section):
        
        # set links
        if len(self.heap) == 0:
            self.start = section
        else:
            self.end.next = section
        
        section.prev = self.end
        self.end = section

        # add to list
        self.heap.append(section)


    def _heapify(self):
        
        # initialize heap. reinitialize after appending!
        self.start.act = self.end.act = False
        self.heap = self.heap[1:-1]
        heapq.heapify(self.heap)

    
    def _remove_one(self):
        
        # l-pop or r-pop, depending on advantage
        if self.start.adv > self.end.adv: self._rpop()
        else: self._lpop()
        

    def _remove_two(self):

        # get smallest active sections from heap
        smallest = None
        while smallest is None:
            section = heapq.heappop(self.heap)
            smallest = (section.act and section or None)

        # check for outer pop
        if smallest.adv > self.start.adv + self.end.adv:
            heapq.heappush(self.heap, smallest)
            self._lpop()
            self._rpop()
            
        # else, do inner pop
        else:
            
            # remove obsolete sections from heap
            smallest.act = smallest.prev.act = smallest.next.act = False

            # insert replacement section into the list
            replacement = Section(
                smallest.prev.adv + smallest.next.adv - smallest.adv,
                smallest.next.bound,
                smallest.next.label,
                smallest.prev.prev,
                smallest.next.next
            )

            # check if replacement is at the edge. if not, push to heap
            if replacement.prev is None and replacement.next is None:
                self.start = self.end = replacement
                replacement.act = False
                
            elif replacement.prev is None:
                self.start = replacement
                self.start.act = False
                self.start.next.prev = self.start

            elif replacement.next is None:
                self.end = replacement
                self.end.act = False
                self.end.prev.next = self.end
            
            else:
                replacement.prev.next = replacement
                replacement.next.prev = replacement
                heapq.heappush(self.heap, replacement)

    
    def _lpop(self):
        
        # remove obsolete section from heap
        self.start.next.act = False

        # l-append new section to list
        self.start = Section(
            self.start.next.adv - self.start.adv,
            self.start.next.bound,
            self.start.label,
            None,
            self.start.next.next
        )

        # reset links
        self.start.act = False
        self.start.next.prev = self.start


    def _rpop(self):
        
        # remove obsolete section from heap
        self.end.prev.act = False

        # r-append new section to list
        self.end = Section(
            self.end.prev.adv - self.end.adv,
            self.end.bound,
            self.end.prev.label,
            self.end.prev.prev,
            None
        )

        # reset links
        self.end.act = False
        self.end.prev.next = self.end
